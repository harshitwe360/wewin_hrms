part of 'verify_otp_bloc.dart';

class VerifyOtpState extends Equatable {
  /// Digits typed so far.
  final String code;
  final bool isSubmitting;
  final bool isSuccess;

  /// Last verify/resend failure, shown once by the screen.
  final String? error;

  /// Set when a code was (re)sent, so the screen can confirm it once.
  final bool codeSent;
  final bool isSending;

  /// Seconds until "Resend" is allowed.
  final int timer;

  const VerifyOtpState({
    this.code = "",
    this.isSubmitting = false,
    this.isSuccess = false,
    this.error,
    this.codeSent = false,
    this.isSending = false,
    this.timer = 0,
  });

  factory VerifyOtpState.initial() => const VerifyOtpState();

  bool get isValid => VerifyOtpBloc.isValidCode(code);
  bool get canResend => timer == 0 && !isSending;

  VerifyOtpState copyWith({
    String? code,
    bool? isSubmitting,
    bool? isSuccess,
    String? error,
    bool clearError = false,
    bool? codeSent,
    bool? isSending,
    int? timer,
  }) {
    return VerifyOtpState(
      code: code ?? this.code,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      error: clearError ? null : (error ?? this.error),
      codeSent: codeSent ?? this.codeSent,
      isSending: isSending ?? this.isSending,
      timer: timer ?? this.timer,
    );
  }

  @override
  List<Object?> get props =>
      [code, isSubmitting, isSuccess, error, codeSent, isSending, timer];
}
