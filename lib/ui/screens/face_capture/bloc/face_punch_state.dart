part of 'face_punch_cubit.dart';

enum FacePunchStep {
  idle,
  checkingLocation,
  startingSession,
  capturing,
  submitting,
  done,
  failed,
}

/// What went wrong, so the screen can offer the right fix.
enum FacePunchIssue {
  none,

  /// Camera permission refused. On Android "deny" and "don't ask again" share
  /// one code, and iOS never re-prompts, so the UI offers Settings too.
  cameraDenied,
  cameraError,
  locationOff,
  locationDenied,
  locationBlocked,
  outsideLocation,
  poseTimeout,
  sessionExpired,
  interrupted,
  signedOut,
  other;

  /// Whether "Open Settings" can fix it.
  bool get needsSettings =>
      this == cameraDenied ||
      this == locationOff ||
      this == locationBlocked;
}

class FacePunchState extends Equatable {
  const FacePunchState({
    this.step = FacePunchStep.idle,
    this.frameIndex = 0,
    this.pose = FacePose.center,
    this.hint = "",
    this.error,
    this.issue = FacePunchIssue.none,
    this.canRetry = true,
    this.result,
  });

  final FacePunchStep step;

  /// Frames captured so far (0..3).
  final int frameIndex;
  final FacePose pose;
  final String hint;
  final String? error;
  final FacePunchIssue issue;
  final bool canRetry;
  final PunchResult? result;

  /// Token rejected; the screen should send the user to login.
  bool get signedOut => issue == FacePunchIssue.signedOut;

  FacePunchState copyWith({
    FacePunchStep? step,
    int? frameIndex,
    FacePose? pose,
    String? hint,
    String? error,
    FacePunchIssue? issue,
    bool? canRetry,
    PunchResult? result,
  }) {
    final FacePunchStep next = step ?? this.step;
    final bool failed = next == FacePunchStep.failed;
    return FacePunchState(
      step: next,
      frameIndex: frameIndex ?? this.frameIndex,
      pose: pose ?? this.pose,
      hint: hint ?? this.hint,
      // Errors only live on the failed step.
      error: failed ? (error ?? this.error) : null,
      issue: failed ? (issue ?? this.issue) : FacePunchIssue.none,
      canRetry: canRetry ?? this.canRetry,
      result: result ?? this.result,
    );
  }

  @override
  List<Object?> get props =>
      [step, frameIndex, pose, hint, error, issue, canRetry, result];
}
