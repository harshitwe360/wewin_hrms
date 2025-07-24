import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sms_autofill/sms_autofill.dart';

import '../../../../core/apis/repository/models/auth_response.dart';
import '../../../../core/apis/repository/resp_api_repo.dart';
import '../../../../core/resources/constants.dart';
import '../../../../core/services/auth/auth_service.dart';
import '../../../../core/services/network_manager.dart';
import '../helper/login_validators.dart';
import '../repository/auth_rest_repo.dart';

part 'login_event.dart';

part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRepository _authRepository = AuthRepository();
  final RestApiRepository _restApiRepository = RestApiRepositoryImp();

  LoginBloc() : super(const LoginState()) {
    on<EmailChanged>(_onEmailChanged);
    on<PasswordChanged>(_onPasswordChanged);
    on<IsPasswordVisible>(_isPasswordVisible);
    on<Submitted>(_onSubmitted);
    // on<GoogleLogin>(_onGoogleSignIn);
    on<RefreshToken>(_onRefreshToken);
    on<FetchMobileNumber>(_onFetchMobileNumber);
    on<Logout>(_onLogout);
  }

  Future<void> _onFetchMobileNumber(FetchMobileNumber event,
      Emitter<LoginState> emit) async {
    try {
      String? mobileNumber = await SmsAutoFill().hint;
      if (mobileNumber != null) {
        if (mobileNumber.length > 10) {
          mobileNumber = mobileNumber.substring(mobileNumber.length - 10);
        }
        emit(state.copyWith(
          email: mobileNumber,
          isEmailInvalid: !LoginValidation.isValidUserName(mobileNumber),
        ));
        // emit(MobileNumberLoaded(mobileNumber, isEditable: false));
      } else {
        // emit(MobileNumberError('Unable to fetch mobile number'));
        // add(MakeFieldEditable());
      }
    } catch (error) {
      // emit(MobileNumberError(error.toString()));
      // add(MakeFieldEditable());
    }
  }

  void _onEmailChanged(EmailChanged event, Emitter<LoginState> emit) {
    emit(state.copyWith(
      email: event.email,
      isEmailInvalid: !LoginValidation.isValidUserName(event.email),
    ));
  }

  void _onPasswordChanged(PasswordChanged event, Emitter<LoginState> emit) {
    emit(state.copyWith(
      password: event.password,
      // isPasswordInvalid: !LoginValidation.isValidPassword(event.password),
    ));
  }

  void _isPasswordVisible(IsPasswordVisible event, Emitter<LoginState> emit) {
    emit(state.copyWith(
      isPasswordVisible: !(state.isPasswordVisible),
    ));
  }

  void _onSubmitted(Submitted event, Emitter<LoginState> emit) async {

    if (!state.isFormValid ||
        !LoginValidation.isValidPassword(state.password)) {
      emit(state.copyWith(
        isEmailInvalid: !LoginValidation.isValidUserName(state.email),
        isPasswordInvalid: !LoginValidation.isValidPassword(state.password),
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
        await _authRepository.login(username: username, password: password);
        if (isLogin) {
            emit(LoginFinishedState(isSuccess: isLogin));
        } else {
          emit(const LoginErrorState(message: ""));
          emit(state.copyWith(
            email: username,
            password: password,
            isEmailInvalid: !LoginValidation.isValidUserName(username),
            isPasswordInvalid: !LoginValidation.isValidPassword(password),
          ));
        }
      } else {
        emit(const LoginErrorState(message: "No internet connection"));
        emit(state.copyWith(
          email: username,
          password: password,
          isEmailInvalid: !LoginValidation.isValidUserName(username),
          isPasswordInvalid: !LoginValidation.isValidPassword(password),
        ));
      }
    } catch (e) {
      emit(LoginErrorState(message: e.toString()));
      emit(state.copyWith(
        email: username,
        password: password,
        isEmailInvalid: !LoginValidation.isValidUserName(username),
        isPasswordInvalid: !LoginValidation.isValidPassword(password),
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

  void _onRefreshToken(RefreshToken event, Emitter<LoginState> emit) async {
    emit(LoginLoadingState());
    try {
      final isConnected = await NetworkManager().isConnectedToInternet();
      if (isConnected) {
        // bool isRefresh = await _authRepository.refreshTokenRequest();
        emit(LoginFinishedState(isSuccess: true));
      } else {
        emit(LoginErrorState(message: "Unable to Refresh Token."));
      }
    } catch (e) {
      emit(LoginErrorState(message: e.toString()));
    }
  }

  void _onLogout(Logout event, Emitter<LoginState> emit) async {
    emit(LoginLoadingState());
    try {
      final isConnected = await NetworkManager().isConnectedToInternet();
      if (isConnected) {
        AuthResponse auth = await AuthService.instance.getCurrentUserData();
        if (!(auth.user != null && auth.user!.userId.isNotEmpty)) {
          // AuthService.instance.clearUserData();
          emit(const LoginErrorState(message: AppConstants.unAuthorization));
          return Future(() => false);
        }

        final punchStatus = await _restApiRepository.getPunchedStatus(variables: {
          "payload":{
            "userId": auth.user!.userId
          }
        });
        final bool isPunchIn = punchStatus.data.isNotEmpty
            && (punchStatus.data.last.inTime.isNotEmpty && punchStatus.data.last.inTime != "00:00:00")
            && (punchStatus.data.last.outTime.isEmpty || punchStatus.data.last.outTime == "00:00:00");

        /*final bool isPunchIn = punchStatus.data.isNotEmpty
            && punchStatus.data.last.inTime.isNotEmpty
            && punchStatus.data.last.outTime.isEmpty;*/
        if(!isPunchIn){
          AuthService.instance.clearUserData();
          emit(LoginFinishedState(isSuccess: true));
        } else {
          emit(LoginErrorState(
              message: "You are not allowed to sign out, before punch-out."));
        }
        // bool isLogout = await _authRepository.logoutRequest();
        // emit(LoginFinishedState(isSuccess: isPunchIn));
      } else {
        emit(LoginErrorState(message: "Unable to logout."));
      }
    } catch (e) {
      emit(LoginErrorState(message: e.toString()));
    }
  }
}
