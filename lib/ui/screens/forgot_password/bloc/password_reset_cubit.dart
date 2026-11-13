import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/network_manager.dart';
import '../../../../core/services/rest_api/app_exception.dart';
import '../../login/helper/login_validators.dart';
import '../../login/repository/auth_rest_repo.dart';

enum ResetStatus { idle, loading, success, failure }

class PasswordResetState extends Equatable {
  const PasswordResetState({this.status = ResetStatus.idle, this.message});

  final ResetStatus status;
  final String? message;

  bool get isLoading => status == ResetStatus.loading;

  @override
  List<Object?> get props => [status, message];
}

/// Forgot-password (send link) and reset-password (token + new password)
/// against WinHRMS.
class PasswordResetCubit extends Cubit<PasswordResetState> {
  PasswordResetCubit({AuthRepository? repository})
      : _repo = repository ?? AuthRepository(),
        super(const PasswordResetState());

  final AuthRepository _repo;

  static const int minPassword = 8;
  static const int maxPassword = 128;
  static const int minTokenLength = 20;

  /// Validation shared by the UI and the cubit. Returns an error or null.
  static String? emailError(String email) =>
      LoginValidation.isValidLoginEmail(email)
          ? null
          : "Enter a valid work email.";

  static String? tokenError(String tokenOrLink) {
    final t = AuthRepository.extractResetToken(tokenOrLink);
    if (t.isEmpty) return "Paste the reset link from your email.";
    if (t.length < minTokenLength) {
      return "That doesn't look like a full reset link. Copy the whole link.";
    }
    return null;
  }

  static String? passwordError(String password) {
    if (password.length < minPassword) {
      return "Use at least $minPassword characters.";
    }
    if (password.length > maxPassword) {
      return "Use at most $maxPassword characters.";
    }
    return null;
  }

  Future<void> sendLink(String email) async {
    if (state.isLoading) return;
    final err = emailError(email);
    if (err != null) {
      return emit(PasswordResetState(status: ResetStatus.failure, message: err));
    }
    await _run(() => _repo.forgotPassword(email: email));
  }

  Future<void> reset({required String tokenOrLink, required String password}) async {
    if (state.isLoading) return;
    final err = tokenError(tokenOrLink) ?? passwordError(password);
    if (err != null) {
      return emit(PasswordResetState(status: ResetStatus.failure, message: err));
    }
    await _run(() => _repo.resetPassword(
        token: AuthRepository.extractResetToken(tokenOrLink),
        newPassword: password));
  }

  Future<void> _run(Future<String> Function() call) async {
    emit(const PasswordResetState(status: ResetStatus.loading));
    try {
      if (!await NetworkManager().isConnectedToInternet()) {
        return emit(const PasswordResetState(
            status: ResetStatus.failure, message: "No internet connection"));
      }
      final String message = await call();
      emit(PasswordResetState(status: ResetStatus.success, message: message));
    } on UnauthorisedException catch (e) {
      emit(PasswordResetState(
          status: ResetStatus.failure,
          message: (e.detail ?? "").isNotEmpty
              ? e.detail
              : "This reset link is invalid or has expired."));
    } on AppException catch (e) {
      emit(PasswordResetState(status: ResetStatus.failure, message: e.message));
    } catch (_) {
      emit(const PasswordResetState(
          status: ResetStatus.failure,
          message: "Something went wrong. Please try again."));
    }
  }
}
