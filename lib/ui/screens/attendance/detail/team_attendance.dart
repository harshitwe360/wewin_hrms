import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/apis/repository/models/filter_model.dart';
import '../../../../core/apis/repository/models/team_attend_user_list.dart';
import '../../../../core/config/config.dart';
import '../../../widgets/filter_calendar_view.dart';
import 'components/attn_user_list.dart';
import 'bloc/att_user_list/att_user_list_bloc.dart';

class TeamAttendance extends StatelessWidget {
  TeamAttendance({super.key});

  final ScrollController _scrollController = ScrollController();
  final List<TeamAttendanceUserItem> _list = [];
  final FilterModel _filter = FilterModel(
      startDate: AppHelper.dateFormat(),
      endDate: AppHelper.dateFormat());

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController
        ..addListener(() {
          if (_scrollController.offset ==
              _scrollController.position.maxScrollExtent &&
              context.read<AttUserListBloc>().isLoadMore &&
              !context.read<AttUserListBloc>().isFetching) {
            context.read<AttUserListBloc>()
              ..isFetching = true
            // ..nextPage += 1
              ..add(AttUserListInitEvent(
                  teamList: context.read<AttUserListBloc>()
                      .selectedTeamOpt,
                  userType: context.read<AttUserListBloc>()
                      .selectedUserType,
                  search: context.read<AttUserListBloc>().search,
                  startDate:
                  context.read<AttUserListBloc>().startDate,
                  endDate:
                  context.read<AttUserListBloc>().endDate));
          }
        }),
        child: Column(
          children: [
            FilterCalendarView(
              filter: _filter,
              callBack: (selectedDay, focusedDay) {
                context.read<AttUserListBloc>()
                  ..nextPage = 0
                  ..startDate = AppHelper.dateFormat(date: selectedDay)
                  ..endDate = AppHelper.dateFormat(date: selectedDay);

                context.read<AttUserListBloc>().add(AttUserListInitEvent(
                    teamList: context.read<AttUserListBloc>().selectedTeamOpt,
                    search: context.read<AttUserListBloc>().search,
                    userType: context.read<AttUserListBloc>().selectedUserType,
                    startDate: AppHelper.dateFormat(date: selectedDay),
                    endDate: AppHelper.dateFormat(date: selectedDay)));
              },
            ),
            Padding(
              padding: PaddingC.boxPadding,
              child: Container(
                constraints: const BoxConstraints(
                    minHeight: 100, minWidth: double.infinity),
                child: BlocConsumer<AttUserListBloc, AttUserListState>(
                  listener: (context, state){
                    if(state is AUUnAuthState){
                      Navigator.pushNamedAndRemoveUntil(
                          context, AppRoutes.login, (r) => false);
                    }
                  },
                  builder: (context, state) {
                    if(state is AULoadedState) {
                      if(!state.attUserList.status
                          && context.read<AttUserListBloc>().currentPage == 1){
                        return ErrorView(error: R.strings.errMsgNoRecord);
                      }
                      if(context.read<AttUserListBloc>().currentPage == 1){
                        _list.clear();
                      }
                      if(state.attUserList.data.isNotEmpty) {
                        _list.addAll(state.attUserList.data);
                      }
                      return AttnUserList(userList: _list, isLoading: false,);
                    }
                    if(state is AUErrorState){
                      return ErrorView(error: state.message);
                    }
                    return AttnUserList(userList: _list, isLoading: true);
                  },
                ),
              ),
            ),
          ],
        ),
    );
  }
}
