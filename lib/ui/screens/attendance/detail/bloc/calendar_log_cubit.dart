import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/apis/repository/models/auth_response.dart';
import '../../../../../core/apis/repository/models/filter_model.dart';
import '../../../../../core/apis/repository/resp_api_repo.dart';
import '../../../../../core/config/r.dart';
import '../../../../../core/services/auth/auth_service.dart';

part 'calendar_log_state.dart';

class CalendarLogCubit extends Cubit<CalendarLogState> {
  CalendarLogCubit() : super(CalendarLogLoadingState());

  final RestApiRepository _restApiRepository = RestApiRepositoryImp();

  Future<void> getCalendarLogData(FilterModel filter) async {
    emit(CalendarLogLoadingState());
    try {
      AuthResponse auth = await AuthService.instance.getCurrentUserData();
      if (!(auth.user != null && auth.user!.userId.isNotEmpty)) {
        AuthService.instance.clearUserData();
        emit(const CalendarLogErrorState(message: AppConstants.unAuthorization));
        return Future(() => false);
      }

      final isConnected = await NetworkManager().isConnectedToInternet();
      if (!isConnected) {
        emit(CalendarLogErrorState(message: R.strings.errAPINoNet));
        return Future(() => false);
      }

      await _restApiRepository.getPunchedLogs(variables: {
        "payload": {
          "fromDate": "${filter.startDate}T${AppConstants.dateFixStart}.000Z",
          "end_date": "${filter.endDate}T${AppConstants.dateFixEnd}.000Z",
          "userId": filter.userId != null && filter.userId!.isNotEmpty
              ? filter.userId
              : auth.user!.userId
        }
      }).then((punchLogs) {
        emit(CalendarLogLoadedState(punchLogs: punchLogs));
      }, onError: (e) {
        if(e.toString() == RestApiRepositoryImp.errorStr){
          emit(CalendarLogUnAuthState(message: e.toString()));
        } else {
          emit(CalendarLogErrorState(message: e.toString()));
        }
      });
    } catch (e) {
      emit(CalendarLogErrorState(message: e.toString()));
    }
  }
}
