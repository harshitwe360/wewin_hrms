part of 'signup_bloc.dart';

class SignupState extends Equatable {
  final List<DdModel> locationList;
  final List<DdModel> processList;
  final bool isNameInvalid;
  final bool isEmailInvalid;
  final bool isAltMobileInvalid;
  final bool isMobileInvalid;
  final bool isAadhaarNoInvalid;
  final bool isLocationInvalid;
  final bool isProcessInvalid;
  final bool isBankAccountInvalid;
  final bool isBankNameInvalid;
  final bool isIfscCodeInvalid;
  final bool isBranchInvalid;

  final String name;
  final String email;
  final String altMobile;
  final String mobile;
  final String aadhaarNo;
  final DdModel? location;
  final DdModel? process;
  final String bankAccount;
  final String bankName;
  final String ifscCode;
  final String branch;

  bool get isFormValid =>
      name.isNotEmpty && !isNameInvalid &&
      // email.isNotEmpty && !isEmailInvalid &&
      // aadhaarNo.isNotEmpty && !isAadhaarNoInvalid &&
      mobile.isNotEmpty && !isMobileInvalid &&
      location!=null && process!=null &&
      altMobile.isNotEmpty && !isAltMobileInvalid;

  SignupState copyWith({
    List<DdModel>? locationList,
    List<DdModel>? processList,
    bool? isNameInvalid,
    bool? isEmailInvalid,
    bool? isAltMobileInvalid,
    bool? isAadhaarNoInvalid,
    bool? isMobileInvalid,
    bool? isLocationInvalid,
    bool? isBankAccountInvalid,
    bool? isProcessInvalid,
    bool? isIfscCodeInvalid,
    bool? isBranchInvalid,
    bool? isBankNameInvalid,
    String? aadhaarNo,
    String? name,
    String? email,
    String? mobile,
    String? altMobile,
    DdModel? location,
    DdModel? process,
    String? bankAccount,
    String? bankName,
    String? ifscCode,
    String? branch,
  }) {
    return SignupState(
      locationList: locationList ?? this.locationList,
      processList: processList ?? this.processList,
      isNameInvalid: isNameInvalid ?? this.isNameInvalid,
      isEmailInvalid: isEmailInvalid ?? this.isEmailInvalid,
      isAltMobileInvalid: isAltMobileInvalid ?? this.isAltMobileInvalid,
      isAadhaarNoInvalid: isAadhaarNoInvalid ?? this.isAadhaarNoInvalid,
      isMobileInvalid: isMobileInvalid ?? this.isMobileInvalid,
      isLocationInvalid: isLocationInvalid ?? this.isLocationInvalid,
      isProcessInvalid: isProcessInvalid ?? this.isProcessInvalid,
      isBankAccountInvalid: isBankAccountInvalid ?? this.isBankAccountInvalid,
      isIfscCodeInvalid: isIfscCodeInvalid ?? this.isIfscCodeInvalid,
      isBranchInvalid: isBranchInvalid ?? this.isBranchInvalid,
      isBankNameInvalid: isBankNameInvalid ?? this.isBankNameInvalid,
      aadhaarNo: aadhaarNo ?? this.aadhaarNo,
      name: name ?? this.name,
      email: email ?? this.email,
      mobile: mobile ?? this.mobile,
      altMobile: altMobile ?? this.altMobile,
      location: location ?? this.location,
      process: process ?? (location!=null? null : this.process),
      bankAccount: bankAccount ?? this.bankAccount,
      bankName: bankName ?? this.bankName,
      ifscCode: ifscCode ?? this.ifscCode,
      branch: branch ?? this.branch,
    );
  }
  const SignupState({
    this.locationList = const [],
    this.processList = const [],
    this.isNameInvalid = false,
    this.isEmailInvalid = false,
    this.isAltMobileInvalid = false,
    this.isAadhaarNoInvalid = false,
    this.isMobileInvalid = false,
    this.isLocationInvalid = false,
    this.isProcessInvalid = false,
    this.isBankAccountInvalid = false,
    this.isIfscCodeInvalid = false,
    this.isBranchInvalid = false,
    this.isBankNameInvalid = false,
    this.location,
    this.process,
    this.aadhaarNo = "",
    this.name = "",
    this.email = "",
    this.mobile = "",
    this.altMobile = "",
    this.bankAccount = "",
    this.bankName = "",
    this.ifscCode = "",
    this.branch = "",
  });

  @override
  List<Object?> get props => [
    locationList, processList,
    isNameInvalid,
    isEmailInvalid,
    isMobileInvalid,
    isAltMobileInvalid,
    isLocationInvalid,
    isProcessInvalid,
    isAadhaarNoInvalid,
    isBankAccountInvalid,
    isBankNameInvalid,
    isIfscCodeInvalid,
    isBranchInvalid,
    name, email, mobile, altMobile, aadhaarNo, location, process,
    branch, ifscCode, bankAccount, bankName
  ];
}

class SignupInitial extends SignupState {}

class SignupLoadingState extends SignupState {}

class SignupLoadedState extends SignupState {
  final bool isSuccess;
  final User? userDetails;

  const SignupLoadedState({required this.isSuccess, this.userDetails});

  @override
  List<Object?> get props => [isSuccess, userDetails];
}

class SignupFinishedState extends SignupState {
  final bool isSuccess;
  final String? mobileNo;

  const SignupFinishedState({required this.isSuccess, this.mobileNo});

  @override
  List<Object?> get props => [isSuccess, mobileNo];
}

class SignupErrorState extends SignupState {
  final String message;

  const SignupErrorState({required this.message});

  @override
  List<Object> get props => [message];
}