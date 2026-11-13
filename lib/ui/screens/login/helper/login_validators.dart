import 'dart:async';

mixin LoginValidation {

  // static final RegExp _emailRegExp = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+$");
  static final RegExp _aadhaarRegExp = RegExp(r"^\+?[0-9]{10,12}$"); //r"^[0-9]{10}$"
  static final RegExp _emailRegExp = RegExp(r"^\+?[0-9]{10}$");
  static final RegExp _loginEmailRegExp =
      RegExp(r"^[^\s@]+@[^\s@]+\.[^\s@]+$");

  /// Login identifier for WinHRMS (email).
  static bool isValidLoginEmail(String email) {
    return email.trim().isNotEmpty && _loginEmailRegExp.hasMatch(email.trim());
  }

  /// Login only checks presence; the server enforces the password policy.
  static bool isValidLoginPassword(String password) => password.isNotEmpty;

  static final RegExp _passwordRegExp = RegExp(r'^[a-zA-Z0-9.!@#$%&’*+/=?^_`{|}~-]{5,30}$'
    // r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,30}$',
  );

  static bool isValidUserName(String username) {
    return (username.isNotEmpty && _aadhaarRegExp.hasMatch(username));
  }
  static bool isValidEmail(String email) {
    return (email.isNotEmpty && _emailRegExp.hasMatch(email));
  }

  static bool isValidPassword(String password) {
    return password.isNotEmpty && _passwordRegExp.hasMatch(password);
  }

  static bool isValidOtp(String otp) {
    return otp.isNotEmpty && otp.length == 4;
  }

  final validateEmail =
  StreamTransformer<String, bool>.fromHandlers(handleData: (email, sink) {
    if (isValidEmail(email)) {
      sink.add(true);
    } else {
      sink.add(false);
    }
  });

  final validateRequireField =
  StreamTransformer<String, bool>.fromHandlers(handleData: (email, sink) {
    if (email.isNotEmpty) {
      sink.add(true);
    } else {
      sink.add(false);
    }
  });


  final validatePassword = StreamTransformer<String, bool>.fromHandlers(
      handleData: (password, sink) {
        if (isValidPassword(password)) {
          sink.add(true);
        } else {
          sink.add(false);
        }
      });
}
