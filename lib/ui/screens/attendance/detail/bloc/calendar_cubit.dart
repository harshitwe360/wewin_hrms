import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/apis/repository/models/auth_response.dart';
import '../../../../../core/apis/repository/models/filter_model.dart';
import '../../../../../core/apis/repository/resp_api_repo.dart';
import '../../../../../core/config/r.dart';
import '../../../../../core/services/auth/auth_service.dart';

part 'calendar_state.dart';

class CalendarCubit extends Cubit<CalendarState> {
  CalendarCubit() : super(CalendarLoadingState());

  final RestApiRepository _restApiRepository = RestApiRepositoryImp();

  Future<void> getCalendarInitData(FilterModel filter) async {
    emit(CalendarLoadingState());
    try {
      AuthResponse auth = await AuthService.instance.getCurrentUserData();
      if (!(auth.user != null && auth.user!.userId.isNotEmpty)) {
        AuthService.instance.clearUserData();
        emit(const CalendarErrorState(message: AppConstants.unAuthorization));
        return Future(() => false);
      }
      final isConnected = await NetworkManager().isConnectedToInternet();
      if (!isConnected) {
        emit(CalendarErrorState(message: R.strings.errAPINoNet));
        return Future(() => false);
      }

      final param = {
        "fromDate": DateTime.parse("${filter.startDate} ${AppConstants.dateFixStart}").toIso8601String(),
        "toDate": DateTime.parse("${filter.endDate} ${AppConstants.dateFixEnd}").toIso8601String()
      };
      if (filter.userId != null && filter.userId!.isNotEmpty) {
        param['userId'] = filter.userId!;
      } else {
        param['userId'] = auth.user!.userId;
      }

      await _restApiRepository.getAttendanceList(variables: {
        "payload":param
      }).then((userAttendance) {
        emit(CalendarLoadedState(userAttendance: userAttendance));
      }, onError: (e) {
        if(e.toString() == RestApiRepositoryImp.errorStr){
          emit(CalendarUnAuthState(message: e.toString()));
        } else {
          emit(CalendarErrorState(message: e.toString()));
        }
      });
    } catch (e) {
      emit(CalendarErrorState(message: e.toString()));
    }
  }
}
