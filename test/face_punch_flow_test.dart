import 'dart:typed_data';

import 'package:attendance/core/apis/repository/attendance_repo.dart';
import 'package:attendance/core/apis/repository/models/auth_response.dart';
import 'package:attendance/core/apis/repository/models/biometric_session.dart';
import 'package:attendance/core/localization/app_localization.dart';
import 'package:attendance/core/services/face_pose_evaluator.dart';
import 'package:attendance/core/services/location_service.dart';
import 'package:attendance/core/services/rest_api/app_exception.dart';
import 'package:attendance/ui/screens/face_capture/bloc/face_punch_cubit.dart';
import 'package:attendance/ui/screens/face_capture/face_capture_screen.dart';
import 'package:attendance/ui/screens/face_capture/face_punch_deps.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';

// ---------- fakes ----------

class FakeApi implements FacePunchApi {
  bool locationOk = true;
  String locationMessage = "";
  List<String> challenge = ["turn_left", "center", "look_up"];
  Duration expiresIn = const Duration(minutes: 2);
  Object? startError;
  Object? completeError;

  int starts = 0;
  int validations = 0;
  List<BiometricFrame>? sentFrames;
  double? sentLat;

  @override
  Future<LocationCheck> validateLocation(
      {required double latitude, required double longitude}) async {
    validations++;
    return LocationCheck(ok: locationOk, message: locationMessage);
  }

  @override
  Future<BiometricSession> startBiometricSession(String action) async {
    starts++;
    if (startError != null) throw startError!;
    final now = DateTime.now().toUtc();
    return BiometricSession.fromJson({
      "session_uuid": "s-$starts",
      "expires_at": now.add(expiresIn).toIso8601String(),
      "challenge": challenge,
      "server_time_ms": now.millisecondsSinceEpoch,
      "min_frames": 3,
      "max_frames": 3,
    });
  }

  @override
  Future<PunchResult> completeBiometricSession({
    required String sessionUuid,
    required String action,
    required List<BiometricFrame> frames,
    double? latitude,
    double? longitude,
  }) async {
    sentFrames = frames;
    sentLat = latitude;
    if (completeError != null) throw completeError!;
    return PunchResult.fromJson({
      "message": action == "in" ? "Punched in" : "Punched out",
      "record": {
        "attendance_date": "2026-11-13",
        "is_punched_in": action == "in",
        "is_punched_out": action == "out",
        "elapsed_seconds": 0,
      },
    });
  }
}

/// Returns queued analyses; repeats the last one when the queue runs out.
class FakeAnalyzer implements FaceAnalyzer {
  FakeAnalyzer(this.queue);
  final List<FaceAnalysis> queue;
  int calls = 0;

  @override
  Future<FaceAnalysis> analyze(XFile file, Uint8List bytes) async {
    calls++;
    return queue.length > 1 ? queue.removeAt(0) : queue.first;
  }

  @override
  Future<void> close() async {}
}

class FakeCamera implements FaceCamera {
  int shots = 0;
  bool disposed = false;

  @override
  bool get isReady => !disposed;

  @override
  Widget preview() => const ColoredBox(color: Colors.grey);

  @override
  Future<XFile> takePicture() async {
    shots++;
    return XFile.fromData(Uint8List.fromList(List.filled(64, shots)),
        name: "shot$shots.jpg", mimeType: "image/jpeg");
  }

  @override
  Future<void> dispose() async => disposed = true;
}

const double _left = FacePoseEvaluator.yawSignForUserLeft * 30.0;
const ok = FaceAnalysis(faceCount: 1, yaw: 0, pitch: 0);
const okLeft = FaceAnalysis(faceCount: 1, yaw: _left, pitch: 0);
const okUp = FaceAnalysis(faceCount: 1, yaw: 0, pitch: 20);
const noFace = FaceAnalysis(faceCount: 0);
const twoFaces = FaceAnalysis(faceCount: 2);

Position _pos() => Position(
    latitude: 23.2599,
    longitude: 77.4126,
    timestamp: DateTime(2026),
    accuracy: 5,
    altitude: 0,
    altitudeAccuracy: 0,
    heading: 0,
    headingAccuracy: 0,
    speed: 0,
    speedAccuracy: 0);

FacePunchCubit _cubit(
  String action,
  FakeApi api, {
  List<FaceAnalysis> faces = const [okLeft, ok, okUp],
  bool locationRequired = true,
  Object? locationError,
  Duration poseTimeout = const Duration(seconds: 5),
}) =>
    FacePunchCubit(
      action: action,
      api: api,
      analyzer: FakeAnalyzer(List.of(faces)),
      loadUser: () async => User(userId: "21", locationMandatory: locationRequired),
      readPosition: () async =>
          locationError != null ? throw locationError : _pos(),
      poseTimeout: poseTimeout,
    );

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await AppLocalization.instance.load(const Locale('en'));
  });

  group('happy path', () {
    test('punch-in: location → session → 3 poses (with retries) → done', () async {
      final api = FakeApi();
      final cubit = _cubit("in", api,
          faces: [noFace, okLeft, twoFaces, ok, okUp]);
      await cubit.prepare();
      expect(api.validations, 1);
      expect(cubit.state.step, FacePunchStep.capturing);
      expect(cubit.state.pose, FacePose.turnLeft);

      final camera = FakeCamera();
      await cubit.runCapture(camera);

      expect(cubit.state.step, FacePunchStep.done);
      expect(cubit.state.result!.message, "Punched in");
      expect(camera.shots, 5, reason: "2 rejected frames were retaken");
      expect(api.sentFrames!.map((f) => f.pose.apiValue),
          ["turn_left", "center", "look_up"]);
      expect(api.sentLat, 23.2599);
      final ts = api.sentFrames!.map((f) => f.capturedAtMs).toList();
      expect(ts[0] <= ts[1] && ts[1] <= ts[2], isTrue);
      await cubit.close();
    });

    test('punch-out never checks location', () async {
      final api = FakeApi()..challenge = ["center"];
      final cubit = _cubit("out", api, faces: [ok]);
      await cubit.prepare();
      await cubit.runCapture(FakeCamera());
      expect(api.validations, 0);
      expect(api.sentLat, isNull);
      expect(cubit.state.step, FacePunchStep.done);
      await cubit.close();
    });

    test('location not required → no location check', () async {
      final api = FakeApi();
      final cubit = _cubit("in", api, locationRequired: false);
      await cubit.prepare();
      expect(api.validations, 0);
      expect(cubit.state.step, FacePunchStep.capturing);
      await cubit.close();
    });
  });

  group('camera permission', () {
    for (final code in [
      "CameraAccessDenied", // Android deny / don't ask again, iOS first deny
      "CameraAccessDeniedWithoutPrompt", // iOS: denied earlier
      "CameraAccessRestricted", // iOS: parental controls / MDM
    ]) {
      test('$code → cameraDenied, Settings + Try again', () async {
        final cubit = _cubit("in", FakeApi());
        await cubit.prepare();
        cubit.cameraFailed(CameraException(code, "denied"));
        expect(cubit.state.step, FacePunchStep.failed);
        expect(cubit.state.issue, FacePunchIssue.cameraDenied);
        expect(cubit.state.issue.needsSettings, isTrue);
        expect(cubit.state.canRetry, isTrue);
        await cubit.close();
      });
    }

    test('other camera error is not a permission problem', () async {
      final cubit = _cubit("in", FakeApi());
      await cubit.prepare();
      cubit.cameraFailed(CameraException("NoCamera", "No camera found"));
      expect(cubit.state.issue, FacePunchIssue.cameraError);
      expect(cubit.state.issue.needsSettings, isFalse);
      await cubit.close();
    });

    test('allow after deny: Try again starts a new session', () async {
      final api = FakeApi();
      final cubit = _cubit("in", api);
      await cubit.prepare();
      cubit.cameraFailed(CameraException("CameraAccessDenied", "denied"));
      await cubit.prepare(); // user allowed in Settings and came back
      expect(api.starts, 2);
      expect(cubit.state.step, FacePunchStep.capturing);
      await cubit.runCapture(FakeCamera());
      expect(cubit.state.step, FacePunchStep.done);
      await cubit.close();
    });
  });

  group('location permission (punch-in, location required)', () {
    final cases = {
      LocationIssue.serviceOff: FacePunchIssue.locationOff,
      LocationIssue.denied: FacePunchIssue.locationDenied,
      LocationIssue.blocked: FacePunchIssue.locationBlocked,
    };
    cases.forEach((loc, expected) {
      test('$loc → $expected', () async {
        final api = FakeApi();
        final cubit = _cubit("in", api,
            locationError: LocationException(loc, "location problem"));
        await cubit.prepare();
        expect(cubit.state.step, FacePunchStep.failed);
        expect(cubit.state.issue, expected);
        expect(cubit.state.error, "location problem");
        expect(api.starts, 0, reason: "no session without location");
        expect(cubit.state.issue.needsSettings,
            loc != LocationIssue.denied, reason: "denied can simply re-ask");
        await cubit.close();
      });
    });

    test('outside geofence → server message, no session', () async {
      final api = FakeApi()
        ..locationOk = false
        ..locationMessage = "You are 2.3 km from the office";
      final cubit = _cubit("in", api);
      await cubit.prepare();
      expect(cubit.state.issue, FacePunchIssue.outsideLocation);
      expect(cubit.state.error, "You are 2.3 km from the office");
      expect(api.starts, 0);
      await cubit.close();
    });
  });

  group('failures during capture', () {
    test('face not matched by server → message, retry works', () async {
      final api = FakeApi()
        ..completeError = BadRequestException("Face does not match");
      final cubit = _cubit("in", api);
      await cubit.prepare();
      await cubit.runCapture(FakeCamera());
      expect(cubit.state.step, FacePunchStep.failed);
      expect(cubit.state.error, "Face does not match");
      expect(cubit.state.canRetry, isTrue);

      api.completeError = null;
      final retry = _cubit("in", api);
      await retry.prepare();
      await retry.runCapture(FakeCamera());
      expect(retry.state.step, FacePunchStep.done);
      await cubit.close();
      await retry.close();
    });

    test('expired session → sessionExpired', () async {
      final api = FakeApi()..expiresIn = const Duration(seconds: -1);
      final cubit = _cubit("in", api);
      await cubit.prepare();
      await cubit.runCapture(FakeCamera());
      expect(cubit.state.issue, FacePunchIssue.sessionExpired);
      expect(api.sentFrames, isNull);
      await cubit.close();
    });

    test('no face for too long → poseTimeout', () async {
      final api = FakeApi();
      final cubit = _cubit("in", api,
          faces: [noFace], poseTimeout: const Duration(milliseconds: 150));
      await cubit.prepare();
      await cubit.runCapture(FakeCamera());
      expect(cubit.state.issue, FacePunchIssue.poseTimeout);
      expect(cubit.state.hint, isNotEmpty);
      await cubit.close();
    });

    test('app backgrounded mid-capture → interrupted', () async {
      final cubit = _cubit("in", FakeApi());
      await cubit.prepare();
      cubit.interrupt();
      expect(cubit.state.issue, FacePunchIssue.interrupted);
      await cubit.close();
    });

    test('session start 401 → signed out, no retry', () async {
      final api = FakeApi()..startError = UnauthorisedException("expired");
      final cubit = _cubit("in", api);
      await cubit.prepare();
      expect(cubit.state.signedOut, isTrue);
      expect(cubit.state.canRetry, isFalse);
      await cubit.close();
    });
  });

  group('screen', () {
    Future<List<Object?>> pumpScreen(WidgetTester t,
        {required FakeApi api,
        required FaceCameraOpener openCamera,
        required List<FacePunchIssue> settingsOpened}) async {
      final popped = <Object?>[];
      await t.pumpWidget(MaterialApp(
        home: Builder(
          builder: (context) => Center(
            child: ElevatedButton(
              onPressed: () async {
                popped.add(await Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => FaceCaptureScreen(
                    action: "in",
                    createCubit: () => _cubit("in", api),
                    openCamera: openCamera,
                    openSettings: (issue) async {
                      settingsOpened.add(issue);
                      return true;
                    },
                  ),
                )));
              },
              child: const Text("open"),
            ),
          ),
        ),
      ));
      await t.tap(find.text("open"));
      return popped;
    }

    Future<void> settle(WidgetTester t) async {
      for (int i = 0; i < 20; i++) {
        await t.runAsync(() => Future.delayed(const Duration(milliseconds: 20)));
        await t.pump(const Duration(milliseconds: 50));
      }
    }

    testWidgets('deny → Open Settings → come back → allow → punched in',
        (t) async {
      final api = FakeApi();
      final settings = <FacePunchIssue>[];
      bool allowed = false;
      final popped = await pumpScreen(t,
          api: api,
          settingsOpened: settings,
          openCamera: () async => allowed
              ? FakeCamera()
              : throw CameraException("CameraAccessDenied", "denied"));
      await settle(t);

      expect(find.textContaining("Camera access is needed"), findsOneWidget);
      expect(find.text("Open Settings"), findsOneWidget);
      expect(find.text("Try again"), findsOneWidget);

      await t.tap(find.text("Open Settings"));
      await t.pump();
      expect(settings, [FacePunchIssue.cameraDenied]);

      // User allows camera in Settings and returns to the app.
      allowed = true;
      t.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await settle(t);

      expect(popped, hasLength(1));
      expect((popped.single as PunchResult).message, "Punched in");
      expect(api.starts, 2);
    });

    testWidgets('deny → Try again (still denied) stays on the error', (t) async {
      final api = FakeApi();
      final popped = await pumpScreen(t,
          api: api,
          settingsOpened: [],
          openCamera: () async =>
              throw CameraException("CameraAccessDeniedWithoutPrompt", "denied"));
      await settle(t);
      await t.tap(find.text("Try again"));
      await settle(t);
      expect(find.text("Open Settings"), findsOneWidget);
      expect(popped, isEmpty);
      await t.tap(find.text("Cancel"));
      await settle(t);
      expect(popped, [null], reason: "cancel returns no result");
    });

    testWidgets('allow on first prompt → punched in', (t) async {
      final api = FakeApi();
      final popped = await pumpScreen(t,
          api: api, settingsOpened: [], openCamera: () async => FakeCamera());
      await settle(t);
      expect(popped, hasLength(1));
      expect(popped.single, isA<PunchResult>());
      expect(api.sentFrames, hasLength(3));
    });
  });
}
