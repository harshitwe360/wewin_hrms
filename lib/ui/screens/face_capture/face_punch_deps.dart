import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import '../../../core/apis/repository/attendance_repo.dart';
import '../../../core/apis/repository/models/auth_response.dart';
import '../../../core/apis/repository/models/biometric_session.dart';
import '../../../core/services/auth/auth_service.dart';
import '../../../core/services/location_service.dart';

/// Seams for the biometric punch flow, so camera, face detection, location
/// and the API can be faked in tests. Defaults use the real implementations.

/// The front camera as the flow needs it.
abstract class FaceCamera {
  bool get isReady;
  Widget preview();
  Future<XFile> takePicture();
  Future<void> dispose();
}

typedef FaceCameraOpener = Future<FaceCamera> Function();

/// [CameraController] wrapper. Throws [CameraException] (e.g. code
/// `CameraAccessDenied`) when permission is refused.
class RealFaceCamera implements FaceCamera {
  RealFaceCamera._(this._c);

  final CameraController _c;

  static Future<FaceCamera> open() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      throw CameraException("NoCamera", "No camera found on this device.");
    }
    final front = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first);
    final c = CameraController(front, ResolutionPreset.medium,
        enableAudio: false, imageFormatGroup: ImageFormatGroup.jpeg);
    try {
      await c.initialize();
      await c.lockCaptureOrientation(DeviceOrientation.portraitUp);
      try {
        await c.setFlashMode(FlashMode.off);
      } catch (_) {/* front cameras often have no flash */}
    } catch (_) {
      await c.dispose();
      rethrow;
    }
    return RealFaceCamera._(c);
  }

  @override
  bool get isReady => _c.value.isInitialized && !_c.value.isTakingPicture;

  @override
  Widget preview() {
    final size = _c.value.previewSize;
    if (size == null) return CameraPreview(_c);
    return FittedBox(
      fit: BoxFit.cover,
      // previewSize is landscape; the UI is portrait.
      child: SizedBox(
          width: size.height, height: size.width, child: CameraPreview(_c)),
    );
  }

  @override
  Future<XFile> takePicture() => _c.takePicture();

  @override
  Future<void> dispose() => _c.dispose();
}

/// One analysed frame.
class FaceAnalysis {
  const FaceAnalysis({
    required this.faceCount,
    this.yaw,
    this.pitch,
    this.faceWidth,
    this.imageWidth,
  });

  final int faceCount;
  final double? yaw;
  final double? pitch;
  final double? faceWidth;

  /// Short side of the image, for the "too far" check.
  final double? imageWidth;
}

abstract class FaceAnalyzer {
  Future<FaceAnalysis> analyze(XFile file, Uint8List bytes);
  Future<void> close();
}

/// ML Kit on-device face detection.
class MlKitFaceAnalyzer implements FaceAnalyzer {
  final FaceDetector _detector = FaceDetector(
    options: FaceDetectorOptions(
      performanceMode: FaceDetectorMode.accurate,
      minFaceSize: 0.15,
    ),
  );

  @override
  Future<FaceAnalysis> analyze(XFile file, Uint8List bytes) async {
    final faces =
        await _detector.processImage(InputImage.fromFilePath(file.path));
    final face = faces.length == 1 ? faces.first : null;
    return FaceAnalysis(
      faceCount: faces.length,
      yaw: face?.headEulerAngleY,
      pitch: face?.headEulerAngleX,
      faceWidth: face?.boundingBox.width,
      imageWidth: await _shortSide(bytes),
    );
  }

  static Future<double?> _shortSide(Uint8List bytes) async {
    try {
      final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
      final d = await ui.ImageDescriptor.encoded(buffer);
      final side = (d.width < d.height ? d.width : d.height).toDouble();
      d.dispose();
      buffer.dispose();
      return side;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> close() => _detector.close();
}

/// The WinHRMS calls the flow makes.
abstract class FacePunchApi {
  Future<LocationCheck> validateLocation(
      {required double latitude, required double longitude});
  Future<BiometricSession> startBiometricSession(String action);
  Future<PunchResult> completeBiometricSession({
    required String sessionUuid,
    required String action,
    required List<BiometricFrame> frames,
    double? latitude,
    double? longitude,
  });
}

class RepositoryFacePunchApi implements FacePunchApi {
  final AttendanceRepository _repo = AttendanceRepository();

  @override
  Future<LocationCheck> validateLocation(
          {required double latitude, required double longitude}) =>
      _repo.validateLocation(latitude: latitude, longitude: longitude);

  @override
  Future<BiometricSession> startBiometricSession(String action) =>
      _repo.startBiometricSession(action);

  @override
  Future<PunchResult> completeBiometricSession({
    required String sessionUuid,
    required String action,
    required List<BiometricFrame> frames,
    double? latitude,
    double? longitude,
  }) =>
      _repo.completeBiometricSession(
          sessionUuid: sessionUuid,
          action: action,
          frames: frames,
          latitude: latitude,
          longitude: longitude);
}

typedef PositionReader = Future<Position> Function();
typedef UserLoader = Future<User?> Function();

Future<Position> defaultPositionReader() =>
    LocationService.instance.currentPosition();

Future<User?> defaultUserLoader() async =>
    (await AuthService.instance.getCurrentUserData()).user;
