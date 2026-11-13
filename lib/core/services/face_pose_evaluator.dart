import '../apis/repository/models/biometric_session.dart';

/// Result of checking one detected frame against the requested pose.
enum PoseCheck { ok, noFace, multipleFaces, tooFar, wrongPose }

/// Head-pose rules for the gate challenge, using ML Kit Euler angles
/// (degrees): yaw = `headEulerAngleY`, pitch = `headEulerAngleX`.
///
/// Pure Dart so it can be unit-tested without a camera.
class FacePoseEvaluator {
  const FacePoseEvaluator();

  /// Max |yaw| / |pitch| for a frontal "center" frame.
  static const double centerMax = 12;

  /// Min |yaw| for a turn.
  static const double turnMin = 20;

  /// Min pitch for "look up".
  static const double lookUpMin = 15;

  /// Face must span at least this fraction of the image width.
  static const double minFaceWidthRatio = 0.22;

  /// Sign of ML Kit yaw when the user turns their head to THEIR left.
  /// ML Kit: positive yaw = face turned toward the right side of the image.
  /// With the front camera's unmirrored capture, the user's left is the
  /// image's right, so +1. VERIFY ON A REAL DEVICE (Android and iOS) and
  /// flip to -1 if turn_left / turn_right are swapped.
  static const int yawSignForUserLeft = 1;

  PoseCheck evaluate({
    required FacePose pose,
    required int faceCount,
    double? yaw,
    double? pitch,
    double? faceWidth,
    double? imageWidth,
  }) {
    if (faceCount == 0) return PoseCheck.noFace;
    if (faceCount > 1) return PoseCheck.multipleFaces;
    if (faceWidth != null && imageWidth != null && imageWidth > 0 &&
        faceWidth / imageWidth < minFaceWidthRatio) {
      return PoseCheck.tooFar;
    }

    final double y = yaw ?? 0;
    final double x = pitch ?? 0;
    final double userLeftYaw = y * yawSignForUserLeft;

    final bool matches = switch (pose) {
      FacePose.center => y.abs() <= centerMax && x.abs() <= centerMax,
      FacePose.turnLeft => userLeftYaw >= turnMin,
      FacePose.turnRight => userLeftYaw <= -turnMin,
      FacePose.lookUp => x >= lookUpMin && y.abs() <= turnMin,
    };
    return matches ? PoseCheck.ok : PoseCheck.wrongPose;
  }

  static String instruction(FacePose pose) => switch (pose) {
        FacePose.center => "Look straight at the camera",
        FacePose.turnLeft => "Slowly turn your head to the left",
        FacePose.turnRight => "Slowly turn your head to the right",
        FacePose.lookUp => "Tilt your head up a little",
      };

  static String hint(PoseCheck check, FacePose pose) => switch (check) {
        PoseCheck.ok => "Hold still…",
        PoseCheck.noFace => "Position your face inside the oval",
        PoseCheck.multipleFaces => "Make sure only you are in the frame",
        PoseCheck.tooFar => "Move closer to the camera",
        PoseCheck.wrongPose => instruction(pose),
      };
}
