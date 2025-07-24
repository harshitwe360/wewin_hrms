import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/apis/repository/models/auth_response.dart';
import '../../../../../core/apis/repository/resp_api_repo.dart';
import '../../../../../core/resources/constants.dart';
import '../../../../../core/services/auth/auth_service.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final RestApiRepository _restApiRepository = RestApiRepositoryImp();
  
  ProfileBloc() : super(ProfileLoading()) {
    on<GetUserDetails>(_onGetUserDetails);
  }
  
  void _onGetUserDetails(GetUserDetails event, emit) async {
    emit(ProfileLoading());
    try{
      AuthResponse auth = await AuthService.instance.getCurrentUserData();
      if (!(auth.user != null && auth.user!.userId.isNotEmpty)) {
        AuthService.instance.clearUserData();
        emit(const ProfileErrorState(message: AppConstants.unAuthorization));
        return Future(() => false);
      }

      await _restApiRepository.getUserDetails(variables: {
        "userId": auth.user!.userId
      }).then((user){
        // print(user);
        emit(ProfileLoadedState(userDetails: user));
      }, onError: (e){
        if(e.toString() == RestApiRepositoryImp.errorStr){
          emit(ProfileUnAuthState(message: e.toString()));
        } else {
          emit(ProfileErrorState(message: e.toString()));
        }
      });
    } catch (e){
      emit(ProfileErrorState(message: e.toString()));
    }
  }
}
