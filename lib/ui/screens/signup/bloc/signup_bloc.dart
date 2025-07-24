import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/apis/repository/models/auth_response.dart';
import '../../../../core/apis/repository/models/dd_model.dart';
import '../../../../core/services/network_manager.dart';
import '../../../../core/utils/fields_validators.dart';
import '../../login/repository/auth_rest_repo.dart';

part 'signup_event.dart';
part 'signup_state.dart';

class SignupBloc extends Bloc<SignupEvent, SignupState> {
  final AuthRepository _authRepository = AuthRepository();
  
  SignupBloc() : super(const SignupState()) {
    on<LoadInitData>(_loadInitData);
    on<NameChanged>(_onNameChanged);
    on<EmailChanged>(_onEmailChanged);
    on<MobileChanged>(_onMobileChanged);
    on<AltMobileChanged>(_onAltMobileChanged);
    on<AadhaarChanged>(_onAadhaarChanged);
    on<LocationChanged>(_onLocationChanged);
    on<ProcessChanged>(_onProcessChanged);
    on<BankAccountChanged>(_onBankAccountChanged);
    on<BankNameChanged>(_onBankNameChanged);
    on<IfscCodeChanged>(_onIfscCodeChanged);
    on<BranchChanged>(_onBranchChanged);
    on<Submitted>(_onSubmitted);
  }

  void _loadInitData(LoadInitData event, Emitter<SignupState> emit) async {
    emit(SignupLoadingState());
    try {
      final List<DdModel> locationList = await _authRepository.getDropDownList(
          variables: {"id": 0, "name": "locations"}
      );
      emit(const SignupFinishedState(isSuccess: false));
      /*if(event.userEdu!=null){
        print("courseList: ${event.userEdu?.id}");
        print("coursOrBoard: ${event.userEdu?.coursOrBoard}");
        DdModel? education = educationList.where(
              (item) => item.nameEng == event.userEdu?.education,
          // orElse: () => null as DdModel,
        ).firstOrNull;
        List<DdModel> courseList = [];
        if(education!=null){
          courseList = await _apiRepository.getDropDownList(
              variables: {"id": education.id ?? 0, "name": "m_course"}
          );
        }
        emit(state.copyWith(educationList: educationList,
            education: education,
            course: courseList.where(
                  (item) => item.nameEng == event.userEdu?.coursOrBoard,
              // orElse: () => null as DdModel,
            ).firstOrNull,
            startYear: yearList.where(
                  (item) => item.nameEng == event.userEdu?.courseFrom,
              // orElse: () => null as DdModel,
            ).firstOrNull,
            endYear: yearList.where(
                  (item) => item.nameEng == event.userEdu?.passingYearOrCourseTo,
              // orElse: () => null as DdModel,
            ).firstOrNull,
            medium: mediumList.where(
                  (item) => item.nameEng == event.userEdu?.schoolMedium,
              // orElse: () => null as DdModel,
            ).firstOrNull,
            university: event.userEdu?.universityInstitute,
            courseType: event.userEdu?.courseType,
            grading: event.userEdu?.gradingOrMarks,
            marks: event.userEdu?.gradingOrMarks,
            courseList: courseList,
            yearList: yearList, mediumList: mediumList));
      } else{*/
        emit(state.copyWith(locationList: locationList));
      // }
    } catch (e) {
      emit(SignupErrorState(message: e.toString()));
    }
  }

  void _onNameChanged(NameChanged event, Emitter<SignupState> emit) {
    emit(state.copyWith(
      name: event.name,
      isNameInvalid: !FieldsValidation.isValidName(event.name),
    ));
  }

  void _onEmailChanged(EmailChanged event, Emitter<SignupState> emit) {
    emit(state.copyWith(
      email: event.email,
      isEmailInvalid: !FieldsValidation.isValidEmail(event.email),
    ));
  }
  
  void _onMobileChanged(MobileChanged event, Emitter<SignupState> emit) {
    emit(state.copyWith(
      mobile: event.mobileNo,
      isMobileInvalid: !FieldsValidation.isValidMobile(event.mobileNo),
    ));
  }

  void _onAltMobileChanged(AltMobileChanged event, Emitter<SignupState> emit) {
    emit(state.copyWith(
      altMobile: event.altMobile,
      isAltMobileInvalid: !FieldsValidation.isValidMobile(event.altMobile),
    ));
  }

  void _onAadhaarChanged(AadhaarChanged event, Emitter<SignupState> emit) {
    emit(state.copyWith(
      aadhaarNo: event.aadhaar,
      isAadhaarNoInvalid: !FieldsValidation.isValidAadhaar(event.aadhaar),
    ));
  }

  void _onLocationChanged(LocationChanged event, Emitter<SignupState> emit) async {
    final List<DdModel> processList = await _authRepository.getDropDownList(
        variables: {"id": event.location?.id ?? 0, "name": "process"}
    );
    emit(state.copyWith(
      processList: processList,
      location: event.location,
      process: null,
      isLocationInvalid: event.location==null,
    ));
    print(state);
  }

  void _onProcessChanged(ProcessChanged event, Emitter<SignupState> emit) {
    emit(state.copyWith(
      process: event.process,
      isProcessInvalid: event.process==null,
    ));
  }

  void _onBankAccountChanged(BankAccountChanged event, Emitter<SignupState> emit) {
    emit(state.copyWith(
      bankAccount: event.bankAccount,
      isBankAccountInvalid: !FieldsValidation.isValidNumber(event.bankAccount,
          required: false, limit: 20),
    ));
  }
  void _onBankNameChanged(BankNameChanged event, Emitter<SignupState> emit) {
    emit(state.copyWith(
      bankName: event.bankName,
      isBankNameInvalid: !FieldsValidation.isValidAlphaNumeric(event.bankName,
          required: false),
    ));
  }
  void _onIfscCodeChanged(IfscCodeChanged event, Emitter<SignupState> emit) {
    emit(state.copyWith(
      ifscCode: event.ifscCode,
      isIfscCodeInvalid: !FieldsValidation.isValidAlphaNumeric(event.ifscCode,
          required: false, limit: 11),
    ));
  }
  void _onBranchChanged(BranchChanged event, Emitter<SignupState> emit) {
    emit(state.copyWith(
      branch: event.branch,
      isBranchInvalid: !FieldsValidation.isValidAlphaNumeric(event.branch,
          required: false),
    ));
  }

  void _onSubmitted(Submitted event, Emitter<SignupState> emit) async {
    print("Submit pressed ${state.isFormValid}");

    if (!state.isFormValid) {
      resetValues(emit, state);
      return;
    }
    final SignupState stateOLd = state;
    final Map<String, dynamic> variables = {
      "userId": 0,
      "aadhaarNo": state.aadhaarNo,
      "fullName": state.name,
      "emailId": state.email,
      "mobileNo": state.mobile,
      "altMobileNo": state.altMobile,
      "gender": "",
      "location": state.location?.nameEng,
      "process": state.process?.nameEng,
      "bankAccountNo": state.bankAccount,
      "ifsc": state.ifscCode,
      "bankName": state.bankName,
      "bankBranch": state.branch,
    };

    emit(SignupLoadingState());
    try {
      final isConnected = await NetworkManager().isConnectedToInternet();
      if (isConnected) {
        await _authRepository.signUp(variables: variables).then((response){
          if (response.status) {
            emit(SignupFinishedState(isSuccess: response.status,
                mobileNo: variables['mobileNo']));
          } else {
            emit(SignupErrorState(message: response.message));
            resetValues(emit, stateOLd);
          }
        });
      } else {
        emit(const SignupErrorState(message: "No internet connection"));
        resetValues(emit, stateOLd);
      }
    } catch (e) {
      emit(SignupErrorState(message: e.toString()));
      resetValues(emit, stateOLd);
    }
  }

  void resetValues(Emitter<SignupState> emit, SignupState stateOLd){
    emit(stateOLd.copyWith(
      isNameInvalid: !FieldsValidation.isValidName(stateOLd.name),
      isAltMobileInvalid: !FieldsValidation.isValidMobile(stateOLd.altMobile),
      isMobileInvalid: !FieldsValidation.isValidMobile(stateOLd.mobile),
      isAadhaarNoInvalid: !FieldsValidation.isValidAadhaar(stateOLd.aadhaarNo),
      isLocationInvalid: stateOLd.location==null,
      isProcessInvalid: stateOLd.process==null,
      isEmailInvalid: !FieldsValidation.isValidEmail(stateOLd.email,
          required: false),
      isBankAccountInvalid: !FieldsValidation.isValidNumber(stateOLd.bankAccount,
          required: false),
      isBankNameInvalid: !FieldsValidation.isValidAlphaNumeric(stateOLd.bankName,
          required: false),
      isIfscCodeInvalid: !FieldsValidation.isValidAlphaNumeric(stateOLd.ifscCode,
          required: false),
      isBranchInvalid: !FieldsValidation.isValidAlphaNumeric(stateOLd.branch,
          required: false),
    ));
  }
}
