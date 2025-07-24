
mixin InputsValidation {

  static RegExp get userNameRegExp => RegExp(r'^[A-Za-z0-9+_.\d]{3,30}$');
  static RegExp get emailRegExp => RegExp(r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$');
  static RegExp get passwordRegExp => RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,25}$');
  static RegExp get nameRegExp => RegExp(r'^[A-Za-z_\-.,\s\d]{3,30}$');
  static RegExp get mobileRegExp => RegExp(r'^[0-9]{10}$');
  static RegExp get aadhaarRegExp => RegExp(r'^[0-9]{12}$');
  static RegExp get partNoRegExp => RegExp(r'^[0-9]{4}$');
  static RegExp get ageRegExp => RegExp(r'^[0-9]{2,3}$');
  static RegExp get addressRegExp => RegExp(r'^[0-9A-Za-z_\-.,/\s\d]{3,150}$');
  static RegExp get voterIdRegExp => RegExp(r'^([a-zA-Z]){3}([0-9]){7}?$');

  static bool isRequiredValidField(String value, {required RegExp regExp}) {
    return (value.isNotEmpty && (regExp).hasMatch(value));
  }

  static bool isValidField(String value, {required RegExp regExp}) {
    return value.isEmpty ? true : (value.isNotEmpty && regExp.hasMatch(value));
  }



/*static final RegExp _domainRegExp = RegExp(
    r'^[-A-Za-z0-9_.]{2,20}$',
  );

  static final RegExp _emailRegExp = RegExp(
    r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$',
  );
  static final RegExp _passwordRegExp = RegExp(
    r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$',
  );
  static final RegExp _usernameRegExp = RegExp(
    r'^[A-Za-z_.\d]{3,30}$',
  );*/
  /*static bool isValidDomain(String domain) {
    return (domain.isNotEmpty && _domainRegExp.hasMatch(domain));
    // return _emailRegExp.hasMatch(email);
  }

  static bool isValidUserName(String username) {
    return (username.isNotEmpty && _usernameRegExp.hasMatch(username));
    // return _emailRegExp.hasMatch(email);
  }
  static bool isValidEmail(String email) {
    return (email.isNotEmpty && _emailRegExp.hasMatch(email));
    // return _emailRegExp.hasMatch(email);
  }

  static bool isValidPassword(String password) {
    return password.isNotEmpty && password.length > 5;
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
      });*/
}
