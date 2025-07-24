part of 'signup_bloc.dart';

abstract class SignupEvent extends Equatable {
  const SignupEvent();
}

class Submitted extends SignupEvent {
  const Submitted();

  @override
  List<Object> get props => [];
}

class LoadInitData extends SignupEvent {
  const LoadInitData();

  @override
  List<Object?> get props => [];
}


class NameChanged extends SignupEvent {
  final String name;

  const NameChanged({required this.name});

  @override
  String toString() => 'NameChanged { name :$name }';

  @override
  List<Object> get props => [name];
}

class EmailChanged extends SignupEvent {
  final String email;

  const EmailChanged({required this.email});

  @override
  String toString() => 'EmailChanged { email :$email }';

  @override
  List<Object> get props => [email];
}

class AltMobileChanged extends SignupEvent {
  final String altMobile;

  const AltMobileChanged({required this.altMobile});

  @override
  List<Object> get props => [altMobile];
}

class MobileChanged extends SignupEvent {
  final String mobileNo;

  const MobileChanged({required this.mobileNo});

  @override
  String toString() => 'mobileNoChanged { mobile No :$mobileNo }';

  @override
  List<Object> get props => [mobileNo];
}

class AadhaarChanged extends SignupEvent {
  final String aadhaar;

  const AadhaarChanged({required this.aadhaar});

  @override
  List<Object> get props => [aadhaar];
}

class LocationChanged extends SignupEvent {
  final DdModel? location;

  const LocationChanged({this.location});

  @override
  List<Object?> get props => [location];
}

class ProcessChanged extends SignupEvent {
  final DdModel? process;

  const ProcessChanged({this.process});

  @override
  List<Object?> get props => [process];
}

class BankAccountChanged extends SignupEvent {
  final String bankAccount;

  const BankAccountChanged({required this.bankAccount});

  @override
  List<Object> get props => [bankAccount];
}

class BankNameChanged extends SignupEvent {
  final String bankName;

  const BankNameChanged({required this.bankName});

  @override
  List<Object> get props => [bankName];
}

class IfscCodeChanged extends SignupEvent {
  final String ifscCode;

  const IfscCodeChanged({required this.ifscCode});

  @override
  List<Object> get props => [ifscCode];
}

class BranchChanged extends SignupEvent {
  final String branch;

  const BranchChanged({required this.branch});

  @override
  List<Object> get props => [branch];
}