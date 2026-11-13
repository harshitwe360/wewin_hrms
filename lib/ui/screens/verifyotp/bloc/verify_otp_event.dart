part of 'verify_otp_bloc.dart';

abstract class VerifyOtpEvent extends Equatable {
  const VerifyOtpEvent();

  @override
  List<Object> get props => [];
}

class OtpCodeChanged extends VerifyOtpEvent {
  final String code;

  const OtpCodeChanged(this.code);

  @override
  List<Object> get props => [code];
}

class OtpTimerStarted extends VerifyOtpEvent {
  final int duration;

  const OtpTimerStarted({this.duration = VerifyOtpBloc.resendCooldown});

  @override
  List<Object> get props => [duration];
}

class OtpTimerTicked extends VerifyOtpEvent {
  final int remaining;

  const OtpTimerTicked(this.remaining);

  @override
  List<Object> get props => [remaining];
}

/// Verifies the code for [mobileNo] (legacy signup API).
class OtpSubmitted extends VerifyOtpEvent {
  final String mobileNo;

  const OtpSubmitted({required this.mobileNo});

  @override
  List<Object> get props => [mobileNo];
}

/// Sends (or re-sends) the signup code to [mobileNo].
class OtpResendRequested extends VerifyOtpEvent {
  final String mobileNo;

  const OtpResendRequested({required this.mobileNo});

  @override
  List<Object> get props => [mobileNo];
}
