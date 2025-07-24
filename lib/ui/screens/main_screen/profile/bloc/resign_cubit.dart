import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/apis/repository/models/auth_response.dart';
import '../../../../../core/apis/repository/resp_api_repo.dart';
import '../../../../../core/services/auth/auth_service.dart';

enum ResignState { initial, loading, success, failure, unauthorised }

class ResignCubit extends Cubit<ResignState> {
  ResignCubit() : super(ResignState.initial);

  final RestApiRepository _restApiRepository = RestApiRepositoryImp();

  Future<void> submitResign(String reason) async {
    emit(ResignState.loading);
    try {
      AuthResponse auth = await AuthService.instance.getCurrentUserData();
      if (!(auth.user != null && auth.user!.userId.isNotEmpty)) {
        AuthService.instance.clearUserData();
        emit(ResignState.unauthorised);
        return Future(() => false);
      }

      await _restApiRepository.submitUserResign(variables: {
        "userId": auth.user!.userId,
        "resionRemarks": reason
      }).then((user){
        emit(ResignState.success);
      }, onError: (e){
        if(e.toString() == RestApiRepositoryImp.errorStr){
          emit(ResignState.unauthorised);
        } else {
          emit(ResignState.failure);
        }
      });
    } catch (e) {
      emit(ResignState.failure);
    }
  }
}
