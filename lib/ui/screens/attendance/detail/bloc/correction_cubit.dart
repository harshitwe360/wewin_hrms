import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/apis/repository/models/auth_response.dart';
import '../../../../../core/apis/repository/resp_api_repo.dart';
import '../../../../../core/services/auth/auth_service.dart';

enum CorrectionState { initial, loading, success, failure, unauthorised }

class CorrectionCubit extends Cubit<CorrectionState> {
  CorrectionCubit() : super(CorrectionState.initial);

  final RestApiRepository _restApiRepository = RestApiRepositoryImp();

  Future<void> submitCorrection(String reason, DateTime date) async {
    emit(CorrectionState.loading);
    try {
      AuthResponse auth = await AuthService.instance.getCurrentUserData();
      if (!(auth.user != null && auth.user!.userId.isNotEmpty)) {
        AuthService.instance.clearUserData();
        emit(CorrectionState.unauthorised);
        return Future(() => false);
      }

      await _restApiRepository.submitAttendCorrection(variables: {
        "userId": auth.user!.userId,
        "Remarks": reason,
        "Date": date.toIso8601String()
      }).then((user){
        emit(CorrectionState.success);
      }, onError: (e){
        if(e.toString() == RestApiRepositoryImp.errorStr){
          emit(CorrectionState.unauthorised);
        } else {
          emit(CorrectionState.failure);
        }
      });
    } catch (e) {
      emit(CorrectionState.failure);
    }
  }
}
