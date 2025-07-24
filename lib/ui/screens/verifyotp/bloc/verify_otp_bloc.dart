import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../login/repository/auth_rest_repo.dart';

part 'verify_otp_event.dart';
part 'verify_otp_state.dart';

class VerifyOtpBloc extends Bloc<VerifyOtpEvent, VerifyOtpState> {
  final AuthRepository _authRepository = AuthRepository();
  static const int initialTimer = 300;
  Timer? _timer;

  VerifyOtpBloc() : super(VerifyOtpState.initial()) {
    on<OtpDigitChanged>(_onDigitChanged);
    on<OtpSubmitted>(_onSubmitted);
    on<OtpTimerStarted>(_onTimerStarted);
    on<OtpTimerTicked>(_onTimerTicked);
    on<OtpResendRequested>(_onResendRequested);
    // Start the timer when BLoC is initialized
    // add(const OtpTimerStarted());
  }

  void _onDigitChanged(OtpDigitChanged event, Emitter<VerifyOtpState> emit) {
    final digits = List<String>.from(state.digits);
    digits[event.index] = event.digit;
    final isValid = digits.every((digit) => digit.isNotEmpty);
    emit(state.copyWith(digits: digits, isValid: isValid));
  }

  void _onSubmitted(OtpSubmitted event, Emitter<VerifyOtpState> emit) async {
    try {
      if (!state.isValid) return;
      emit(state.copyWith(isSubmitting: true, isFailure: false, isSuccess: false));

      await _authRepository.verifyOTP(variables: {
        "mobileNo": event.emailId,
        "otp": state.digits.join()
      }).then((response){
        if (response.status) {
          emit(state.copyWith(isSubmitting: false, isSuccess: true));
        } else {
          emit(state.copyWith(isSubmitting: false, isFailure: true));
        }
      });
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, isFailure: true));
    }
  }

  void _onTimerStarted(OtpTimerStarted event, Emitter<VerifyOtpState> emit) {
    _timer?.cancel();
    emit(state.copyWith(timer: event.duration, canResend: false));

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final newTime = state.timer - 1;
      if (newTime > 0) {
        add(OtpTimerTicked(newTime));
      } else {
        timer.cancel();
        add(const OtpTimerTicked(0));
      }
    });
  }

  void _onTimerTicked(OtpTimerTicked event, Emitter<VerifyOtpState> emit) {
    emit(state.copyWith(timer: event.remaining, isSuccess: false,
        isFailure: false, canResend: event.remaining == 0));
  }

  void _onResendRequested(OtpResendRequested event,
      Emitter<VerifyOtpState> emit) async {

    // emit(state.copyWith(isSubmitting: true, isFailure: false, isOtpSent: false));

    await _authRepository.sentOTP(variables: {
      "mobileNo": event.emailId
    }).then((response){
      if (response.status) {
        // emit(state.copyWith(isSubmitting: false, isOtpSent: true));
        // add(const OtpTimerStarted(duration: initialTimer));
      } else {
        _timer?.cancel();
        emit(state.copyWith(isSubmitting: false, canResend: true));
      }
    });
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
