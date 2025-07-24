part of 'verify_otp_bloc.dart';

abstract class VerifyOtpEvent extends Equatable {
  const VerifyOtpEvent();

  @override
  List<Object> get props => [];
}

class OtpDigitChanged extends VerifyOtpEvent {
  final int index;
  final String digit;

  const OtpDigitChanged({required this.index, required this.digit});

  @override
  List<Object> get props => [index, digit];
}

class OtpTimerStarted extends VerifyOtpEvent {
  final int duration;

  const OtpTimerStarted({this.duration = 60});

  @override
  List<Object> get props => [duration];
}

class OtpTimerTicked extends VerifyOtpEvent {
  final int remaining;

  const OtpTimerTicked(this.remaining);

  @override
  List<Object> get props => [remaining];
}

class OtpSubmitted extends VerifyOtpEvent {
  final String emailId;

  const OtpSubmitted({required this.emailId});

  @override
  List<Object> get props => [emailId];
}

class OtpResendRequested extends VerifyOtpEvent {
  final String emailId;

  const OtpResendRequested({required this.emailId});

  @override
  List<Object> get props => [emailId];
}