part of 'login_bloc.dart';

abstract class LoginEvent extends Equatable {

  const LoginEvent();

  @override
  List<Object> get props => [];
}

class Submitted extends LoginEvent {
  const Submitted();

  @override
  List<Object> get props => [];
}

class RefreshToken extends LoginEvent {
  const RefreshToken();

  @override
  List<Object> get props => [];
}

class FetchMobileNumber extends LoginEvent {}

class EmailChanged extends LoginEvent {
  final String email;

  const EmailChanged({required this.email});

  @override
  String toString() => 'EmailChanged { email :$email }';

  @override
  List<Object> get props => [email];
}

class PasswordChanged extends LoginEvent {
  final String password;

  const PasswordChanged({required this.password});

  @override
  List<Object> get props => [password];
}

class IsPasswordVisible extends LoginEvent {
  // final String password;

  // const PasswordChanged({required this.password});
  const IsPasswordVisible();
  @override
  List<Object> get props => [];
}

class Logout extends LoginEvent {
  const Logout();

  @override
  List<Object> get props => [];
}

/*class GoogleLogin extends LoginEvent {
  const GoogleLogin({required this.email});

  final String email;

  @override
  List<Object> get props => [email];
}*/
