part of 'verify_otp_bloc.dart';

class VerifyOtpState extends Equatable {
  final List<String> digits;
  final bool isValid;
  final bool isSubmitting;
  final bool isSuccess;
  final bool isFailure;
  final bool isUnAuth;
  final int timer;
  final bool canResend;

  const VerifyOtpState({
    required this.digits,
    this.isValid = false,
    this.isSubmitting = false,
    this.isSuccess = false,
    this.isFailure = false,
    this.isUnAuth = false,
    this.timer = 300,
    this.canResend = false,
  });

  factory VerifyOtpState.initial() {
    return VerifyOtpState(digits: List.filled(4, ''));
  }

  VerifyOtpState copyWith({
    List<String>? digits,
    bool? isValid,
    bool? isSubmitting,
    bool? isSuccess,
    bool? isFailure,
    bool? isUnAuth,
    int? timer,
    bool? canResend,
  }) {
    return VerifyOtpState(
      digits: digits ?? this.digits,
      isValid: isValid ?? this.isValid,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      isFailure: isFailure ?? this.isFailure,
      isUnAuth: isUnAuth ?? this.isUnAuth,
      timer: timer ?? this.timer,
      canResend: canResend ?? this.canResend,
    );
  }

  @override
  List<Object> get props => [
    digits,
    isValid,
    isSubmitting,
    isSuccess,
    isFailure,
    isUnAuth,
    timer,
    canResend,
  ];
}