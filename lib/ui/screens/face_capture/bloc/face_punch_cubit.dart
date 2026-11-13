import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/apis/repository/attendance_repo.dart';
import '../../../../core/apis/repository/models/auth_response.dart';
import '../../../../core/apis/repository/models/biometric_session.dart';
import '../../../../core/services/face_pose_evaluator.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/services/rest_api/app_exception.dart';
import '../face_punch_deps.dart';

part 'face_punch_state.dart';

/// Biometric punch: location check (punch-in, when required) → start
/// session → capture 3 challenge frames with on-device face/pose checks →
/// complete.
class FacePunchCubit extends Cubit<FacePunchState> {
  FacePunchCubit({
    required this.action,
    FacePunchApi? api,
    FaceAnalyzer? analyzer,
    PositionReader? readPosition,
    UserLoader? loadUser,
    this.poseTimeout = const Duration(seconds: 25),
  })  : assert(action == "in" || action == "out"),
        _api = api ?? RepositoryFacePunchApi(),
        _analyzer = analyzer ?? MlKitFaceAnalyzer(),
        _readPosition = readPosition ?? defaultPositionReader,
        _loadUser = loadUser ?? defaultUserLoader,
        super(const FacePunchState());

  /// "in" or "out".
  final String action;

  /// Max time to hit one pose before giving up.
  final Duration poseTimeout;

  final FacePunchApi _api;
  final FaceAnalyzer _analyzer;
  final PositionReader _readPosition;
  final UserLoader _loadUser;
  final FacePoseEvaluator _evaluator = const FacePoseEvaluator();

  BiometricSession? _session;
  Position? _position;
  int _runId = 0;

  /// Steps 1-2: location (punch-in only, when the account requires it) and
  /// session start. On success the screen opens the camera.
  Future<void> prepare() async {
    _runId++;
    _session = null;
    _position = null;
    emit(const FacePunchState());
    try {
      if (action == "in") {
        final User? user = await _loadUser();
        if (user?.locationMandatory ?? false) {
          emit(state.copyWith(step: FacePunchStep.checkingLocation));
          _position = await _readPosition();
          final LocationCheck check = await _api.validateLocation(
              latitude: _position!.latitude, longitude: _position!.longitude);
          if (!check.ok) {
            return _fail(
                check.message.isNotEmpty
                    ? check.message
                    : "You are outside the allowed punch location.",
                issue: FacePunchIssue.outsideLocation);
          }
        }
      }

      emit(state.copyWith(step: FacePunchStep.startingSession));
      _session = await _api.startBiometricSession(action);
      emit(state.copyWith(
        step: FacePunchStep.capturing,
        frameIndex: 0,
        pose: _session!.poseAt(0),
        hint: FacePoseEvaluator.instruction(_session!.poseAt(0)),
      ));
    } catch (e) {
      _failFrom(e);
    }
  }

  /// Steps 3-4: capture frames from [camera], then complete the session.
  Future<void> runCapture(FaceCamera camera) async {
    final BiometricSession? session = _session;
    if (session == null || state.step != FacePunchStep.capturing) return;
    final int runId = _runId;
    final List<BiometricFrame> frames = [];

    try {
      for (int i = 0; i < BiometricSession.requiredFrames; i++) {
        final FacePose pose = session.poseAt(i);
        _emitIfLive(runId, state.copyWith(
            frameIndex: i, pose: pose,
            hint: FacePoseEvaluator.instruction(pose)));

        final BiometricFrame? frame =
            await _capturePose(camera, session, pose, runId);
        if (frame == null) return; // cancelled, failed or timed out
        frames.add(frame);
      }

      if (!_isLive(runId)) return;
      if (session.isExpired()) {
        return _fail("The verification session expired. Please try again.",
            issue: FacePunchIssue.sessionExpired);
      }

      emit(state.copyWith(step: FacePunchStep.submitting,
          frameIndex: BiometricSession.requiredFrames, hint: "Verifying…"));
      final PunchResult result = await _api.completeBiometricSession(
        sessionUuid: session.sessionUuid,
        action: action,
        frames: frames,
        latitude: _position?.latitude,
        longitude: _position?.longitude,
      );
      if (_isLive(runId)) {
        emit(state.copyWith(step: FacePunchStep.done, result: result));
      }
    } catch (e) {
      if (_isLive(runId)) _failFrom(e);
    }
  }

  Future<BiometricFrame?> _capturePose(FaceCamera camera,
      BiometricSession session, FacePose pose, int runId) async {
    final DateTime deadline = DateTime.now().add(poseTimeout);
    while (_isLive(runId)) {
      if (DateTime.now().isAfter(deadline)) {
        _fail("Could not verify your face. "
            "${FacePoseEvaluator.instruction(pose)} and try again.",
            issue: FacePunchIssue.poseTimeout);
        return null;
      }
      if (session.isExpired()) {
        _fail("The verification session expired. Please try again.",
            issue: FacePunchIssue.sessionExpired);
        return null;
      }
      if (!camera.isReady) {
        await Future.delayed(const Duration(milliseconds: 150));
        continue;
      }

      final XFile shot = await camera.takePicture();
      final int capturedAtMs = session.serverNowMs();
      try {
        final Uint8List bytes = await shot.readAsBytes();
        final FaceAnalysis a = await _analyzer.analyze(shot, bytes);
        final PoseCheck check = _evaluator.evaluate(
          pose: pose,
          faceCount: a.faceCount,
          yaw: a.yaw,
          pitch: a.pitch,
          faceWidth: a.faceWidth,
          imageWidth: a.imageWidth,
        );
        if (!_isLive(runId)) return null;

        if (check != PoseCheck.ok) {
          emit(state.copyWith(hint: FacePoseEvaluator.hint(check, pose)));
          continue;
        }

        final String b64 = base64Encode(bytes);
        if (b64.length > BiometricFrame.maxBase64Length) {
          _fail("Captured image is too large. Please try again.");
          return null;
        }
        return BiometricFrame(
            capturedAtMs: capturedAtMs, pose: pose, imageBase64: b64);
      } finally {
        _deleteQuietly(shot.path);
      }
    }
    return null;
  }

  /// Camera could not be opened (permission denied, no camera, ...).
  void cameraFailed(Object error) => _failFrom(error);

  /// Called when the app is backgrounded or the camera is lost mid-capture.
  void interrupt() {
    if (state.step == FacePunchStep.capturing) {
      _fail("Face capture was interrupted. Please try again.",
          issue: FacePunchIssue.interrupted);
    }
  }

  void _deleteQuietly(String path) {
    if (path.isEmpty) return;
    try {
      File(path).deleteSync();
    } catch (_) {}
  }

  bool _isLive(int runId) => !isClosed && runId == _runId;

  void _emitIfLive(int runId, FacePunchState s) {
    if (_isLive(runId)) emit(s);
  }

  /// Maps an error to a user message and the issue kind the UI acts on.
  void _failFrom(Object e) {
    if (e is UnauthorisedException) {
      return _fail("Your session has expired. Please sign in again.",
          issue: FacePunchIssue.signedOut, canRetry: false);
    }
    if (e is LocationException) {
      return _fail(e.message,
          issue: switch (e.issue) {
            LocationIssue.serviceOff => FacePunchIssue.locationOff,
            LocationIssue.denied => FacePunchIssue.locationDenied,
            LocationIssue.blocked => FacePunchIssue.locationBlocked,
          });
    }
    if (e is CameraException) {
      if (isCameraPermissionError(e.code)) {
        return _fail(
            "Camera access is needed to verify your face. "
            "Allow camera access for this app and try again.",
            issue: FacePunchIssue.cameraDenied);
      }
      return _fail("Camera error: ${e.description ?? e.code}",
          issue: FacePunchIssue.cameraError);
    }
    final String msg = e is AppException ? e.message : e.toString();
    debugPrint("FacePunch failed: $e");
    _fail(msg.isEmpty ? "Something went wrong. Please try again." : msg);
  }

  /// camera_avfoundation / camera_android_camerax permission codes.
  static bool isCameraPermissionError(String code) =>
      code.startsWith("CameraAccessDenied") || code == "CameraAccessRestricted";

  void _fail(String message,
      {FacePunchIssue issue = FacePunchIssue.other, bool canRetry = true}) {
    if (isClosed) return;
    _runId++; // stops any running capture loop
    emit(state.copyWith(
        step: FacePunchStep.failed,
        error: message,
        issue: issue,
        canRetry: canRetry));
  }

  @override
  Future<void> close() async {
    _runId++;
    await _analyzer.close();
    return super.close();
  }
}
