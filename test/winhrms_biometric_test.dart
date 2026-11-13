import 'package:attendance/core/apis/repository/models/biometric_session.dart';
import 'package:attendance/core/services/face_pose_evaluator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BiometricSession', () {
    final received = DateTime(2026, 11, 13, 10);
    BiometricSession session(List<String> challenge, {String? expires}) =>
        BiometricSession.fromJson({
          "session_uuid": "abc-123",
          "expires_at": expires ?? "2026-11-13T10:02:00Z",
          "challenge": challenge,
          "server_time_ms":
              DateTime.utc(2026, 11, 13, 10).millisecondsSinceEpoch,
          "min_frames": 3,
          "max_frames": 3,
        }, receivedAt: received);

    test('parses challenge poses', () {
      final s = session(["center", "turn_left", "look_up"]);
      expect(s.sessionUuid, "abc-123");
      expect(s.challenge,
          [FacePose.center, FacePose.turnLeft, FacePose.lookUp]);
    });

    test('poseAt pads short or empty challenges', () {
      expect(session(["turn_right"]).poseAt(2), FacePose.turnRight);
      expect(session([]).poseAt(0), FacePose.center);
    });

    test('serverNowMs follows server clock, not device clock', () {
      final s = session(["center"]);
      final later = received.add(const Duration(milliseconds: 1500));
      expect(s.serverNowMs(later),
          DateTime.utc(2026, 11, 13, 10).millisecondsSinceEpoch + 1500);
    });

    test('expiry uses server clock', () {
      final s = session(["center"]);
      expect(s.isExpired(received.add(const Duration(seconds: 119))), isFalse);
      expect(s.isExpired(received.add(const Duration(seconds: 121))), isTrue);
    });

    test('frame json matches PunchBiometricFrame', () {
      const f = BiometricFrame(
          capturedAtMs: 1, pose: FacePose.turnRight, imageBase64: "xyz");
      expect(f.toJson(),
          {"captured_at_ms": 1, "action": "turn_right", "image_base64": "xyz"});
    });
  });

  group('FacePoseEvaluator', () {
    const e = FacePoseEvaluator();
    const left = FacePoseEvaluator.yawSignForUserLeft * 30.0;

    test('face count and distance', () {
      expect(e.evaluate(pose: FacePose.center, faceCount: 0), PoseCheck.noFace);
      expect(e.evaluate(pose: FacePose.center, faceCount: 2),
          PoseCheck.multipleFaces);
      expect(
          e.evaluate(pose: FacePose.center, faceCount: 1,
              yaw: 0, pitch: 0, faceWidth: 50, imageWidth: 480),
          PoseCheck.tooFar);
    });

    test('center', () {
      expect(e.evaluate(pose: FacePose.center, faceCount: 1, yaw: 3, pitch: -4),
          PoseCheck.ok);
      expect(e.evaluate(pose: FacePose.center, faceCount: 1, yaw: 25),
          PoseCheck.wrongPose);
    });

    test('turns are directional', () {
      expect(e.evaluate(pose: FacePose.turnLeft, faceCount: 1, yaw: left),
          PoseCheck.ok);
      expect(e.evaluate(pose: FacePose.turnRight, faceCount: 1, yaw: left),
          PoseCheck.wrongPose);
      expect(e.evaluate(pose: FacePose.turnRight, faceCount: 1, yaw: -left),
          PoseCheck.ok);
    });

    test('look up', () {
      expect(e.evaluate(pose: FacePose.lookUp, faceCount: 1, pitch: 20),
          PoseCheck.ok);
      expect(e.evaluate(pose: FacePose.lookUp, faceCount: 1, pitch: 2),
          PoseCheck.wrongPose);
    });
  });
}
