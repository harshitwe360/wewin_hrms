import '../../../utils/server_time.dart';

/// Poses the WinHRMS gate challenge can ask for
/// (`PunchBiometricFrame.action`: center | turn_left | turn_right | look_up).
enum FacePose {
  center("center"),
  turnLeft("turn_left"),
  turnRight("turn_right"),
  lookUp("look_up");

  const FacePose(this.apiValue);

  final String apiValue;

  static FacePose fromApi(String value) => FacePose.values.firstWhere(
      (p) => p.apiValue == value,
      orElse: () => FacePose.center);
}

/// WinHRMS `PunchBiometricSessionResponse`.
class BiometricSession {
  const BiometricSession({
    required this.sessionUuid,
    required this.expiresAt,
    required this.challenge,
    required this.serverTimeMs,
    required this.minFrames,
    required this.maxFrames,
    required this.receivedAt,
  });

  final String sessionUuid;
  final DateTime? expiresAt;
  final List<FacePose> challenge;
  final int serverTimeMs;
  final int minFrames;
  final int maxFrames;

  /// Local clock when the response arrived; anchors [serverNowMs].
  final DateTime receivedAt;

  /// Number of frames to send. The complete endpoint takes exactly 3.
  static const int requiredFrames = 3;

  /// Pose for frame [index], following the server challenge and repeating
  /// its last pose (or center) if the challenge is shorter than 3.
  FacePose poseAt(int index) {
    if (challenge.isEmpty) return FacePose.center;
    return index < challenge.length ? challenge[index] : challenge.last;
  }

  /// Server-clock milliseconds now, so frame timestamps line up with the
  /// session window even if the device clock is off.
  int serverNowMs([DateTime? now]) =>
      serverTimeMs +
      (now ?? DateTime.now()).difference(receivedAt).inMilliseconds;

  bool isExpired([DateTime? now]) {
    if (expiresAt == null) return false;
    final int nowMs = serverNowMs(now);
    return nowMs >= expiresAt!.millisecondsSinceEpoch;
  }

  factory BiometricSession.fromJson(Map<String, dynamic> json,
          {DateTime? receivedAt}) =>
      BiometricSession(
        sessionUuid: json["session_uuid"]?.toString() ?? "",
        expiresAt: ServerTime.parse(json["expires_at"]),
        challenge: (json["challenge"] is List)
            ? (json["challenge"] as List)
                .map((e) => FacePose.fromApi(e.toString()))
                .toList()
            : const [],
        serverTimeMs: (json["server_time_ms"] as num?)?.toInt() ??
            DateTime.now().millisecondsSinceEpoch,
        minFrames: (json["min_frames"] as num?)?.toInt() ?? requiredFrames,
        maxFrames: (json["max_frames"] as num?)?.toInt() ?? requiredFrames,
        receivedAt: receivedAt ?? DateTime.now(),
      );
}

/// One captured frame for `PunchBiometricCompleteRequest.frames`.
class BiometricFrame {
  const BiometricFrame({
    required this.capturedAtMs,
    required this.pose,
    required this.imageBase64,
  });

  final int capturedAtMs;
  final FacePose pose;
  final String imageBase64;

  /// Server limit on `image_base64` length.
  static const int maxBase64Length = 700000;

  Map<String, dynamic> toJson() => {
        "captured_at_ms": capturedAtMs,
        "action": pose.apiValue,
        "image_base64": imageBase64,
      };
}
