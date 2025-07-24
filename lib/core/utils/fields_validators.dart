import 'dart:async';

mixin FieldsValidation {


  static final RegExp _nameRegExp = RegExp(r"^[a-zA-Z\s]{3,50}$");
  static final RegExp _numberRegExp = RegExp(r"^[0-9]+$");
  static final RegExp _alphaRegExp = RegExp(r"^[a-zA-Z\s]+$");
  static final RegExp _alphaNumericRegExp = RegExp(r"^[a-zA-Z0-9\s]+$");
  static final RegExp _salaryRegExp = RegExp(r"^\+?[0-9]{1,7}$");
  static final RegExp _decimalRegExp = RegExp(r"^[0-9]+(\.[0-9]{1,2})?$");
  static final RegExp _mobileRegExp = RegExp(r"^\+?[0-9]{10}$"); //r"^[0-9]{10}$"
  static final RegExp _aadhaarRegExp = RegExp(r"^\+?[0-9]{12}$"); //r"^[0-9]{10}$"
  static final RegExp _emailRegExp = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+$");
  static final RegExp _passwordRegExp = RegExp(
    r'^[a-zA-Z0-9.!@#$%^&’*+/=?_`{|}~-]{8,30}$',
    // r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,30}$',
  );
  static final RegExp _addressRegExp = RegExp(r"^[A-Za-z0-9\s/.,-]{2,100}$");
  static final RegExp _cityRegExp = RegExp(r"^[A-Za-z\s-]{2,45}$");
  static final RegExp _skillsRegExp = RegExp(r"^([A-Za-z0-9\s]+)(,\s*[A-Za-z0-9\s]+)*$");
  static final RegExp _universityRegExp = RegExp(r"^[A-Za-z0-9\s.'’-]{2,100}$");

  static bool isValidUserName(String username) {
    return (username.trim().isNotEmpty);
  }

  static bool isValidEmail(String email, {bool required = false}) {
    if(required) {
      return (email.trim().isNotEmpty && _emailRegExp.hasMatch(email));
    }
    return email.trim().isNotEmpty ? (_emailRegExp.hasMatch(email)) : true;
  }
  static bool isValidName(String value, {bool required = true}) {
    if(required) {
      return (value.trim().isNotEmpty && _nameRegExp.hasMatch(value));
    }
    return value.trim().isNotEmpty ? (_nameRegExp.hasMatch(value)) : true;
  }

  static bool isValidMobile(String value, {bool required = true}) {
    if(required){
      return (value.trim().isNotEmpty && _mobileRegExp.hasMatch(value));
    }
    return value.trim().isNotEmpty ? (_mobileRegExp.hasMatch(value)) : true;
  }

  static bool isValidAlpha(String value, 
      {bool required = true, int limit = 50}) {
    if(required){
      return (value.trim().isNotEmpty && _alphaRegExp.hasMatch(value)
          && value.length <= limit);
    }
    return value.trim().isNotEmpty
        ? (_alphaRegExp.hasMatch(value) && value.length <= limit)
        : true;
  }

  static bool isValidNumber(String value,
      {bool required = true, int limit = 50}) {
    if(required){
      return (value.trim().isNotEmpty && value.length <= limit
          && _numberRegExp.hasMatch(value));
    }
    return value.trim().isNotEmpty
        ? (_numberRegExp.hasMatch(value) && value.length <= limit)
        : true;
  }

  static bool isValidAlphaNumeric(String value,
      {bool required = true, int limit = 50}) {
    if(required){
      return (value.trim().isNotEmpty && value.length <= limit
          && _alphaNumericRegExp.hasMatch(value));
    }
    return value.trim().isNotEmpty
        ? (_alphaNumericRegExp.hasMatch(value) && value.length <= limit)
        : true;
  }

  static bool isValidDecimal(String value, 
      {bool required = true, int limit = 5}) {
    if(required){
      return (value.trim().isNotEmpty && _decimalRegExp.hasMatch(value)
          && value.length <= limit);
    }
    return value.trim().isNotEmpty
        ? (_decimalRegExp.hasMatch(value) && value.length <= limit)
        : true;
  }

  static bool isValidPassword(String password) {
    return password.trim().isNotEmpty && _passwordRegExp.hasMatch(password);
  }

  static bool isValidOtp(String otp) {
    return otp.trim().isNotEmpty && otp.length == 4;
  }

  static bool isValidAadhaar(String value, {bool required = false}) {
    if(required) {
      return (value.trim().isNotEmpty && _aadhaarRegExp.hasMatch(value));
    }
    return value.trim().isNotEmpty ? (_aadhaarRegExp.hasMatch(value)) : true;
  }
  static bool isValidAddress(String value, {bool required = true}) {
    if(required) {
      return (value.trim().isNotEmpty && _addressRegExp.hasMatch(value));
    }
    return value.trim().isNotEmpty ? (_addressRegExp.hasMatch(value)) : true;
  }
  static bool isValidCity(String value, {bool required = true}) {
    if(required) {
      return (value.trim().isNotEmpty && _cityRegExp.hasMatch(value));
    }
    return value.trim().isNotEmpty ? (_cityRegExp.hasMatch(value)) : true;
  }
  
  static bool isValidSalary(String value, {bool required = true}) {
    if(required) {
      return (value.trim().isNotEmpty && _salaryRegExp.hasMatch(value));
    }
    return value.trim().isNotEmpty ? (_salaryRegExp.hasMatch(value)) : true;
  }
  
  static bool isValidSkills(String value, {bool required = true}) {
    if(required) {
      return (value.trim().isNotEmpty && _skillsRegExp.hasMatch(value));
    }
    return value.trim().isNotEmpty ? (_skillsRegExp.hasMatch(value)) : true;
  }

  static bool isValidUniversity(String value, {bool required = true}) {
    if(required) {
      return (value.trim().isNotEmpty && _universityRegExp.hasMatch(value));
    }
    return value.trim().isNotEmpty ? (_universityRegExp.hasMatch(value)) : true;
  }

  static bool isRequireField(String value) {
    return value.trim().isNotEmpty;
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
    if (email.trim().isNotEmpty) {
      sink.add(true);
    } else {
      sink.add(false);
    }
  });
}
