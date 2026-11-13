import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/apis/repository/models/team_attend_user_list.dart';
import '../../../../../core/config/config.dart';
import '../bloc/att_user_list/att_user_list_bloc.dart';
import 'filter_button_view.dart';
import 'filter_selected_ui_view.dart';
import 'present_user_item.dart';

class AttnUserList extends StatefulWidget {
  const AttnUserList({super.key,
    required this.userList, required this.isLoading});
  final List<TeamAttendanceUserItem> userList;
  final bool isLoading;

  @override
  State<AttnUserList> createState() => _AttnUserListState();
}

class _AttnUserListState extends State<AttnUserList> {
  final TextEditingController _controllerSearch = TextEditingController();
  List<TeamAttendanceUserItem> listItems = [];

  @override
  void initState() {
    _controllerSearch.text = context.read<AttUserListBloc>().search;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    listItems = widget.userList;
    return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(children: [
            Expanded(child: _searchField()),
            const SizedBox(width: 5),
            const FilterIconBtnView()
          ]),
          const FilterSelectedUiView(),
          Container(
            decoration: BoxDecorationX.panel,
            constraints:
                const BoxConstraints(minHeight: 400, minWidth: double.infinity),
            margin: EdgeInsets.only(
                top: R.dimens.panelBoxT * 2, bottom: R.dimens.panelBoxB),
            child: listItems.isNotEmpty
                ? ListView.separated(
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    padding: const EdgeInsets.all(16.0),
                    itemCount: listItems.length + 1,
                    itemBuilder: (context, index) {
                      if (index == listItems.length
                          && context.read<AttUserListBloc>().isLoadMore) {
                        return const LoaderView();
                      }
                      if(index == listItems.length){
                        return Container();
                      }
                      return PresentUserItem(
                        // item: listItems[0], index: 0);
                          item: listItems[index],
                          index: index);
                    },
                    separatorBuilder: (context, index) {
                      return const Divider();
                    },
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 86),
                    child: Center(child: Text(R.strings.errMsgNoRecord))),
          )
        ]);
  }

  Widget _searchField() {
    return Container(
      decoration: BoxDecorationX.panel,
      child: TextField(
        // key: UniqueKey(),
        controller: _controllerSearch,
        textInputAction: TextInputAction.search,
        onChanged: filterSearchServer,
        maxLines: 1,
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
          filled: false,
          fillColor: AppColors.searchField,
          constraints: const BoxConstraints(maxHeight: 42, maxWidth: 327),
          contentPadding: const EdgeInsets.only(top: 8.0),
          hintText: R.strings.txtSearch,
          border: InputBorder.none,
          prefixIcon: const Icon(Icons.search, color: AppColors.black87),
        ),
      ),
    );
  }

  void filterSearchServer(String query) {
    context.read<AttUserListBloc>().search = query;
    if (query.isNotEmpty) {
      if (query.length > 2) {
        context.read<AttUserListBloc>()
          ..currentPage = 1
          ..nextPage = 0;
        context.read<AttUserListBloc>().add(AttUserListInitEvent(
            teamList: context.read<AttUserListBloc>().selectedTeamOpt,
            userType: context.read<AttUserListBloc>().selectedUserType,
            search: query,
            startDate: context.read<AttUserListBloc>().startDate,
            endDate: context.read<AttUserListBloc>().endDate));
      }
    } else {
      context.read<AttUserListBloc>()
        ..currentPage = 1
        ..nextPage = 0;
      context.read<AttUserListBloc>().add(AttUserListInitEvent(
          teamList: context.read<AttUserListBloc>().selectedTeamOpt,
          userType: context.read<AttUserListBloc>().selectedUserType,
          search: "",
          startDate: context.read<AttUserListBloc>().startDate,
          endDate: context.read<AttUserListBloc>().endDate));
    }
  }
}
