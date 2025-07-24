part of 'login_bloc.dart';

class LoginState extends Equatable {
  final bool isEmailInvalid;
  final bool isPasswordInvalid;
  final bool isPasswordVisible;
  final String email;
  final String password;

  bool get isFormValid =>
      email.isNotEmpty &&
      !isEmailInvalid &&
      password.isNotEmpty &&
      !isPasswordInvalid;

  LoginState copyWith({
      bool? isEmailInvalid,
      bool? isPasswordInvalid,
      bool? isPasswordVisible,
      String? email,
      String? password}) {
    return LoginState(
      isEmailInvalid: isEmailInvalid ?? this.isEmailInvalid,
      isPasswordInvalid: isPasswordInvalid ?? this.isPasswordInvalid,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }

  const LoginState({
    this.isEmailInvalid = false, //default true
    this.isPasswordInvalid = false, //default true
    this.isPasswordVisible = false,
    this.email = "", //default "siddharth+666@we360.ai"
    this.password = "", //default "Pa55w0rd!!"
  });

  @override
  List<Object> get props => [
        isEmailInvalid,
        isPasswordInvalid,
        isPasswordVisible,
        email,
        password
      ];
}

class LoginInitState extends LoginState {}

class LoginLoadingState extends LoginState {}

class LoginFinishedState extends LoginState {
  final bool isSuccess;

  const LoginFinishedState({required this.isSuccess});

  @override
  List<Object> get props => [isSuccess];
}

class LoginErrorState extends LoginState {
  final String message;

  const LoginErrorState({required this.message});

  @override
  List<Object> get props => [message];
}
