import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/apis/repository/models/auth_response.dart';
import '../../../../../../core/apis/repository/models/team_model.dart';
import '../../../../../../core/apis/repository/resp_api_repo.dart';
import '../../../../../../core/config/r.dart';
import '../../../../../../core/services/auth/auth_service.dart';
import '../../../../../../core/utils/app_helper.dart';

part 'att_user_list_event.dart';

part 'att_user_list_state.dart';

class AttUserListBloc extends Bloc<AttUserListEvent, AttUserListState> {
  final RestApiRepository _restApiRepository = RestApiRepositoryImp();

  String startDate = AppHelper.dateFormat();
  String endDate = AppHelper.dateFormat();
  String search = "";
  String? selectedUserType;
  List<TeamItem> selectedTeamOpt = [];
  List<String> filterLabels = [];

  bool isFetching = false;
  bool isLoadMore = true;
  int currentPage = 1;
  int nextPage = 0;
  int limit = 10;

  AttUserListBloc() : super(AULoadingState()) {
    on<AttUserListInitEvent>(getAttUserListData);
  }

  Future<void> getAttUserListData(AttUserListInitEvent event, emit) async {
    emit(AULoadingState());
    try {
      AuthResponse auth = await AuthService.instance.getCurrentUserData();
      if (!(auth.user != null && auth.user!.userId.isNotEmpty)) {
        AuthService.instance.clearUserData();
        emit(const AUErrorState(message: AppConstants.unAuthorization));
        return Future(() => false);
      }
      final isConnected = await NetworkManager().isConnectedToInternet();
      if (!isConnected) {
        emit(AUErrorState(message: R.strings.errAPINoNet));
        return Future(() => false);
      }

      await _restApiRepository.getAttendanceUserList(variables: {
        "page": nextPage <= 0 ? 1 : nextPage,
        "limit": limit,
        "group_id": event.teamList.isNotEmpty
            ? event.teamList.map((e) => e.id).join(', ')
            : "",
        "name": event.search ?? "",
        "sort_by": "total_working_time",
        "desc": true,
        "datewise": true,
        "attendance_type": getUserType(event.userType ?? ""),
        "start_date":
            DateTime.parse("${event.startDate} ${AppConstants.dateFixStart}").toIso8601String(),
        "end_date":
            DateTime.parse("${event.endDate} ${AppConstants.dateFixEnd}").toIso8601String()
        // "id": auth.user!.pk
      }).then((userAttendance) {
        isLoadMore = !(nextPage >= userAttendance.pagination.nextPage);
        isFetching = false;
        limit = userAttendance.pagination.limit;
        currentPage = userAttendance.pagination.currentPage;
        nextPage = userAttendance.pagination.nextPage;
        emit(AULoadedState(attUserList: userAttendance));
      }, onError: (e) {
        if(e.toString() == RestApiRepositoryImp.errorStr){
          emit(AUUnAuthState(message: e.toString()));
        } else {
          emit(AUErrorState(message: e.toString()));
        }
      });
    } catch (e) {
      emit(AUErrorState(message: e.toString()));
    }
  }

  String getUserType(String type) {
    // print("type = $type");
    return type == AppConstants.filterUserOptList[1]
        ? "P"
        : type == AppConstants.filterUserOptList[2]
            ? "A"
            : "All";
  }
}
