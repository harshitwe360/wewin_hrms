import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/config/r.dart';
import '../bloc/att_user_list/att_user_list_bloc.dart';

class FilterSelectedUiView extends StatelessWidget {
  const FilterSelectedUiView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AttUserListBloc, AttUserListState>(
            builder: (context, state) {
              final List<String> fStrList = context.read<AttUserListBloc>().filterLabels;
              return fStrList.isNotEmpty
                  ? Container(
                height: 42.0,
                margin: EdgeInsets.only(bottom: R.dimens.panelBoxB),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: fStrList.length,
                  itemBuilder: (context, index) {
                    return filterItemSelected(context, fStrList[index], index);
                  },
                ),
              ): Container();
            },
          );
  }

  Widget filterItemSelected(BuildContext context, String name, index) {
    return Container(
      margin: const EdgeInsets.only(top: 8.0, right: 6.0),
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      decoration: const BoxDecoration(
        color: AppColors.filterLabelBox,
        borderRadius: BorderRadius.all(
          Radius.circular(20.0),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(name),
          const SizedBox(width: 8.0),
          InkWell(
            onTap: () {
              context.read<AttUserListBloc>()
                ..filterLabels.removeAt(index)
                ..selectedTeamOpt.removeWhere((r) => r.name == name)
                ..currentPage = 1
                ..nextPage = 0;

              context.read<AttUserListBloc>().selectedUserType == name
                  ? context.read<AttUserListBloc>().selectedUserType = null
                  : null;

              context.read<AttUserListBloc>().add(AttUserListInitEvent(
                  teamList: context.read<AttUserListBloc>().selectedTeamOpt,
                  search: context.read<AttUserListBloc>().search,
                  userType: context.read<AttUserListBloc>().selectedUserType,
                  startDate: context.read<AttUserListBloc>().startDate,
                  endDate: context.read<AttUserListBloc>().endDate));
            },
            child: Container(
              padding: const EdgeInsets.all(2.0),
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: Colors.black12),
              child: const Icon(
                Icons.close,
                size: 12.0,
                color: Colors.white70,
              ),
            ),
          )
        ],
      ),
    );
  }
}
