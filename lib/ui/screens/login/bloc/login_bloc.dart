import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/apis/repository/attendance_repo.dart';
import '../../../../core/services/rest_api/app_exception.dart';
import '../../../../core/services/auth/auth_service.dart';
import '../../../../core/services/network_manager.dart';
import '../helper/login_validators.dart';
import '../repository/auth_rest_repo.dart';

part 'login_event.dart';

part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRepository _authRepository = AuthRepository();
  final AttendanceRepository _attendanceRepository = AttendanceRepository();

  LoginBloc() : super(const LoginState()) {
    on<EmailChanged>(_onEmailChanged);
    on<PasswordChanged>(_onPasswordChanged);
    on<IsPasswordVisible>(_isPasswordVisible);
    on<Submitted>(_onSubmitted);
    // on<GoogleLogin>(_onGoogleSignIn);
    on<RefreshToken>(_onRefreshToken);
    on<Logout>(_onLogout);
    on<SendLoginOtp>(_onSendLoginOtp);
    on<VerifyLoginOtp>(_onVerifyLoginOtp);
  }

  void _onEmailChanged(EmailChanged event, Emitter<LoginState> emit) {
    emit(state.copyWith(
      email: event.email,
      isEmailInvalid: !LoginValidation.isValidLoginEmail(event.email),
    ));
  }

  void _onPasswordChanged(PasswordChanged event, Emitter<LoginState> emit) {
    emit(state.copyWith(
      password: event.password,
      // isPasswordInvalid: !LoginValidation.isValidLoginPassword(event.password),
    ));
  }

  void _isPasswordVisible(IsPasswordVisible event, Emitter<LoginState> emit) {
    emit(state.copyWith(
      isPasswordVisible: !(state.isPasswordVisible),
    ));
  }

  void _onSubmitted(Submitted event, Emitter<LoginState> emit) async {

    if (!state.isFormValid ||
        !LoginValidation.isValidLoginPassword(state.password)) {
      emit(state.copyWith(
        isEmailInvalid: !LoginValidation.isValidLoginEmail(state.email),
        isPasswordInvalid: !LoginValidation.isValidLoginPassword(state.password),
      ));
      return;
    }
    final String username = state.email;
    final String password = state.password;
    emit(LoginLoadingState());
    try {
      final isConnected = await NetworkManager().isConnectedToInternet();
      if (isConnected) {
        bool isLogin =
        await _authRepository.login(email: username, password: password);
        if (isLogin) {
            emit(LoginFinishedState(isSuccess: isLogin));
        } else {
          emit(const LoginErrorState(message: ""));
          emit(state.copyWith(
            email: username,
            password: password,
            isEmailInvalid: !LoginValidation.isValidLoginEmail(username),
            isPasswordInvalid: !LoginValidation.isValidLoginPassword(password),
          ));
        }
      } else {
        emit(const LoginErrorState(message: "No internet connection"));
        emit(state.copyWith(
          email: username,
          password: password,
          isEmailInvalid: !LoginValidation.isValidLoginEmail(username),
          isPasswordInvalid: !LoginValidation.isValidLoginPassword(password),
        ));
      }
    } catch (e) {
      emit(LoginErrorState(message: e.toString()));
      emit(state.copyWith(
        email: username,
        password: password,
        isEmailInvalid: !LoginValidation.isValidLoginEmail(username),
        isPasswordInvalid: !LoginValidation.isValidLoginPassword(password),
      ));
    }
  }

  /*void _onGoogleSignIn(GoogleLogin event, Emitter<LoginState> emit) async {
    emit(LoginLoadingState());
    try {
      if (event.email.isEmpty) {
        emit(const LoginErrorState(message: "Unable to login."));
        return;
      }
      final isConnected = await NetworkManager().isConnectedToInternet();
      if (isConnected) {
        bool isLogin = await _authRepository.googleLogin(email: event.email);
        if (isLogin) {
          final bool isUserDetails = await _authRepository.getUserDetails();
          if (isUserDetails) {
            emit(LoginFinishedState(isSuccess: isLogin));
          } else {
            emit(const LoginErrorState(message: "Unable to get details."));
          }
        } else {
          emit(const LoginErrorState(message: "Unable to login."));
        }
      } else {
        emit(const LoginErrorState(message: "No internet connection"));
      }
    } catch (e) {
      emit(LoginErrorState(message: e.toString()));
    }
  }*/

  Future<void> _onSendLoginOtp(
      SendLoginOtp event, Emitter<LoginState> emit) async {
    final String email = event.email.trim();
    if (!LoginValidation.isValidLoginEmail(email)) {
      emit(state.copyWith(email: email, isEmailInvalid: true));
      return;
    }
    final LoginState form = state.copyWith(email: email, isEmailInvalid: false);
    emit(LoginLoadingState());
    try {
      if (!await NetworkManager().isConnectedToInternet()) {
        emit(const LoginErrorState(message: "No internet connection"));
      } else {
        final sent = await _authRepository.requestLoginOtp(email: email);
        emit(LoginOtpSentState(
            message: sent.message.isNotEmpty
                ? sent.message : "A one-time code was sent to $email",
            expiresInSeconds: sent.expiresInSeconds));
      }
    } catch (e) {
      emit(LoginErrorState(message: _cleanError(e)));
    }
    emit(form);
  }

  Future<void> _onVerifyLoginOtp(
      VerifyLoginOtp event, Emitter<LoginState> emit) async {
    final String email = event.email.trim();
    final LoginState form = state.copyWith(email: email);
    emit(LoginLoadingState());
    try {
      if (!await NetworkManager().isConnectedToInternet()) {
        emit(const LoginErrorState(message: "No internet connection"));
        emit(form);
        return;
      }
      await _authRepository.verifyLoginOtp(email: email, otp: event.otp.trim());
      emit(LoginFinishedState(isSuccess: true));
    } catch (e) {
      emit(LoginErrorState(message: _cleanError(e)));
      emit(form);
    }
  }

  /// "BadRequest: msg" → "msg" for snackbars.
  String _cleanError(Object e) =>
      e.toString().replaceFirst(RegExp(r'^(Exception|[A-Za-z ]+): '), '');

  /// App start: confirm the stored token with `GET /api/auth/me`.
  void _onRefreshToken(RefreshToken event, Emitter<LoginState> emit) async {
    emit(LoginLoadingState());
    try {
      final bool isValid = await _authRepository.validateSession();
      emit(LoginFinishedState(isSuccess: isValid));
    } on ForbiddenException catch (e) {
      emit(LoginErrorState(message: e.toString()));
    } on Exception catch (e) {
      // Offline / timeout / server error: the token was not rejected, so keep
      // the cached session and let screens retry.
      final bool hasToken =
          ((await AuthService.instance.getToken()) ?? "").isNotEmpty;
      if (hasToken) {
        emit(LoginFinishedState(isSuccess: true));
      } else {
        emit(LoginErrorState(message: e.toString()));
      }
    }
  }

  /// No server logout route: clear the local session. Blocked while the
  /// user is punched in (from `GET /api/attendance/today`).
  void _onLogout(Logout event, Emitter<LoginState> emit) async {
    emit(LoginLoadingState());
    try {
      final isConnected = await NetworkManager().isConnectedToInternet();
      if (!isConnected) {
        emit(const LoginErrorState(message: "No internet connection"));
        return;
      }
      final today = await _attendanceRepository.getToday();
      if (today.isWorking) {
        emit(const LoginErrorState(
            message: "You are not allowed to sign out, before punch-out."));
        return;
      }
      await AuthService.instance.clearUserData();
      emit(LoginFinishedState(isSuccess: true));
    } on UnauthorisedException {
      // Token already rejected; session was cleared by ApiBaseHelper.
      await AuthService.instance.clearUserData();
      emit(LoginFinishedState(isSuccess: true));
    } catch (e) {
      emit(LoginErrorState(message: e.toString()));
    }
  }
}
