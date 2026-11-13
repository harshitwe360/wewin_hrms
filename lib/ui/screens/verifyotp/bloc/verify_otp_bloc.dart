import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/rest_api/app_exception.dart';
import '../../login/repository/auth_rest_repo.dart';

part 'verify_otp_event.dart';
part 'verify_otp_state.dart';

/// Signup mobile verification (legacy `HRMSAccounts/SendOTP` / `VerifyOTP`).
class VerifyOtpBloc extends Bloc<VerifyOtpEvent, VerifyOtpState> {
  final AuthRepository _authRepository = AuthRepository();
  Timer? _timer;

  /// 6 digits, as in the API docs (`"otp": "123456"`).
  static const int codeLength = 6;
  static const int resendCooldown = 60;

  static bool isValidCode(String code) =>
      RegExp('^\\d{$codeLength}\$').hasMatch(code);

  VerifyOtpBloc() : super(VerifyOtpState.initial()) {
    on<OtpCodeChanged>(_onCodeChanged);
    on<OtpSubmitted>(_onSubmitted);
    on<OtpTimerStarted>(_onTimerStarted);
    on<OtpTimerTicked>(_onTimerTicked);
    on<OtpResendRequested>(_onResendRequested);
  }

  void _onCodeChanged(OtpCodeChanged event, Emitter<VerifyOtpState> emit) {
    emit(state.copyWith(code: event.code, clearError: true));
  }

  Future<void> _onSubmitted(
      OtpSubmitted event, Emitter<VerifyOtpState> emit) async {
    if (!state.isValid || state.isSubmitting) return;
    emit(state.copyWith(isSubmitting: true, clearError: true, codeSent: false));
    try {
      final response = await _authRepository.verifyOTP(variables: {
        "mobileNo": event.mobileNo,
        "otp": state.code,
      });
      if (response.status) {
        emit(state.copyWith(isSubmitting: false, isSuccess: true));
      } else {
        emit(state.copyWith(isSubmitting: false,
            error: "Invalid code. Please try again."));
      }
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, error: _message(e,
          fallback: "Invalid code. Please try again.")));
    }
  }

  Future<void> _onResendRequested(
      OtpResendRequested event, Emitter<VerifyOtpState> emit) async {
    if (state.isSending) return;
    emit(state.copyWith(isSending: true, clearError: true, codeSent: false));
    try {
      final response =
          await _authRepository.sentOTP(variables: {"mobileNo": event.mobileNo});
      if (response.status) {
        emit(state.copyWith(isSending: false, codeSent: true));
        add(const OtpTimerStarted());
        return;
      }
      emit(state.copyWith(isSending: false,
          error: "Couldn't send the code. Please try again."));
    } catch (e) {
      emit(state.copyWith(isSending: false, error: _message(e,
          fallback: "Couldn't send the code. Please try again.")));
    }
  }

  void _onTimerStarted(OtpTimerStarted event, Emitter<VerifyOtpState> emit) {
    _timer?.cancel();
    emit(state.copyWith(timer: event.duration));
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final int next = state.timer - 1;
      add(OtpTimerTicked(next < 0 ? 0 : next));
      if (next <= 0) timer.cancel();
    });
  }

  void _onTimerTicked(OtpTimerTicked event, Emitter<VerifyOtpState> emit) {
    emit(state.copyWith(timer: event.remaining, codeSent: false));
  }

  String _message(Object e, {required String fallback}) {
    if (e is AppException) return e.message;
    final String s = e.toString().replaceFirst(RegExp(r'^Exception: '), '');
    return s.isEmpty ? fallback : s;
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
