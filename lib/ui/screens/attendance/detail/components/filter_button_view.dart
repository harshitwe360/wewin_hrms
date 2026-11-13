import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../../core/apis/repository/models/team_model.dart';
import '../../../../../core/config/config.dart';
import '../bloc/att_user_list/att_user_list_bloc.dart';

class FilterIconBtnView extends StatefulWidget{
  const FilterIconBtnView({super.key});

  @override
  State<FilterIconBtnView> createState() => _FilterIconBtnViewState();
}

class _FilterIconBtnViewState extends State<FilterIconBtnView> {

  String _selectedUserOpt = "";
  List<TeamItem> _selectedTeamOpt = [];
  bool isDialogOpen = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final int filterCount = context.read<AttUserListBloc>().filterLabels.length;

    return InkWell(
      onTap: () async {
        // await context.read<TeamsCubit>().getTeamListData();

        _selectedUserOpt = context.read<AttUserListBloc>().selectedUserType ??
            AppConstants.filterUserOptList.first;
        _selectedTeamOpt = context.read<AttUserListBloc>().selectedTeamOpt;

        if(!isDialogOpen) {
          _showBottomSheet(context);
        }
      },
      child: Container(
        decoration: BoxDecorationX.panel,
        height: 42.0,
        width: 42.0,
        child: Stack(
          children: <Widget>[
            Center(child: SvgPicture.asset(
                R.icon.filterDark,
                width: 26, height: 26,
                semanticsLabel: R.strings.btnFilter,
                colorFilter: const ColorFilter.mode(
                    AppColors.colorAccent , BlendMode.srcIn)
            )),
            filterCount > 0 ? Positioned(
              right: 6,
              top: 8,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: AppColors.filterIcon,
                  borderRadius: BorderRadius.circular(6),
                ),
                constraints: const BoxConstraints(
                  minWidth: 14,
                  minHeight: 14,
                ),
                child: Text("$filterCount",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ) : Container()
          ],
        ),
      ),
    );
  }

  void _showBottomSheet(BuildContext context) async {
    // List<PunchLogs> logsList = [];
    isDialogOpen=true;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => DraggableScrollableSheet(
            initialChildSize: 0.75,
            minChildSize: 0.2,
            maxChildSize: 0.95,
            expand: false,
            builder: (_, scrollController) => Padding(
                        padding:
                        const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                        child: Stack(
                          children: [
                            SingleChildScrollView(
                              controller: scrollController,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Center(
                                    child: VerticalLine(
                                        color: Colors.black12,
                                        radius: 30.0,
                                        width: 64,
                                        height: 5),
                                  ),
                                  const SizedBox(height: 12.0),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(R.strings.txtFilter,
                                            style:
                                            Theme.of(context).textTheme.largeXXValue),
                                      ),
                                      SvgPicture.asset(
                                          R.icon.filterDark,
                                          width: 26, height: 26,
                                          semanticsLabel: R.strings.btnFilter,
                                          colorFilter: const ColorFilter.mode(
                                              AppColors.black87 , BlendMode.srcIn)
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 28.0),
                                  _filterCtgHeading(context, R.strings.txtSelectUser, Icons.person_outline),
                                  const SizedBox(height: 16.0),
                                  radioBtnSet(AppConstants.filterUserOptList),
                                  // _setTeamFilterView(context, setState),
                                  const SizedBox(height: 48.0),
                                ],
                              ),
                            ),
                            _filterBtnSet(context),
                          ],
                        ),
                      ),
          )
    ).then((value) {
      isDialogOpen = false;
    });
  }

  /*Widget _setTeamFilterView(BuildContext context, StateSetter setState){
    return BlocBuilder<TeamsCubit, TeamsState>(
            builder: (context, state) {
              if(state is TeamLoadedState) {
                return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  const SizedBox(height: 28.0),
                  _filterCtgHeading(
                      context, R.strings.txtSelectTeam,
                      Icons.group_outlined),
                  const SizedBox(height: 16.0),
                  teamBtnSet(state.teamList),
                ]);
              }
              return Container();
            },
          );
  }*/

  Widget _filterCtgHeading(BuildContext context, String label, IconData? icon){
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 12.0),
          child: Icon(icon ?? Icons.group_outlined,
              color: AppColors.black87),
        ),
        Expanded(
          child: Text(
              label,
              style: Theme.of(context).textTheme.largeXValue),
        ),
      ],
    );
  }

  Widget teamBtnSet(List<TeamItem> options){
    return StatefulBuilder(
      builder: (BuildContext context1, StateSetter setState) {
        return Wrap(
          spacing: 4.0,
          runSpacing: 4.0,
          alignment: WrapAlignment.start,
          children: options.map((option) => InkWell(
            onTap: () {
                (_selectedTeamOpt.where((p) => p.name == option.name).firstOrNull != null)
                    ? _selectedTeamOpt.removeWhere((r) => r.name == option.name)
                    : _selectedTeamOpt.add(option);

                setState(() {});
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(color: AppColors.colorAccent.withValues(alpha: 0.2)),
                color: (_selectedTeamOpt.where((p) => p.name == option.name).firstOrNull != null)
                    ? AppColors.colorAccent : null,
              ),
              child: Text(option.name, style: TextStyle(
                  fontSize: 13.0,
                  color: (_selectedTeamOpt.where((p) => p.name == option.name).firstOrNull != null)
                      ? Colors.white : null)
              ),
            ),
          ),
          ).toList(),
        );
      }
    );
  }

  Widget radioBtnSet(List<dynamic> options){
    return StatefulBuilder(
      builder: (BuildContext context1, StateSetter setState) {
        return Wrap(
          spacing: 4.0,
          runSpacing: 4.0,
          alignment: WrapAlignment.start,
          children: options.map((option) => InkWell(
              onTap: () {
                setState(() { _selectedUserOpt = option; });
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(color: AppColors.colorAccent.withValues(alpha: 0.2)),
                  color: (_selectedUserOpt == option)
                      ? AppColors.colorAccent : null,
                ),
                child: Text(option, style: TextStyle(
                  fontSize: 13.0,
                  color: (_selectedUserOpt == option)
                        ? Colors.white : null)
                ),
              ),
            ),
          ).toList(),
        );
      }
    );
  }

  Widget _filterBtnSet(BuildContext context1){
    return Positioned(
      bottom: 0, // Change this value to adjust the position of the button
      left: 0,
      right: 0,
      child: Container(
        color: AppColors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: ButtonFull(
                border: Border.all(
                  color: AppColors.black12,
                  width: 2.0,
                ),
                padding: const EdgeInsets.only(right: 8),
                label: R.strings.btnClear,
                backgroundColor: AppColors.white,
                labelColor: AppColors.black54,
                isShadow: false,
                onTap: () {
                  _selectedUserOpt = AppConstants.filterUserOptList.first;
                  _selectedTeamOpt = [];

                  context.read<AttUserListBloc>()
                    ..filterLabels = []
                    ..selectedUserType = _selectedUserOpt
                    ..selectedTeamOpt = _selectedTeamOpt
                    ..currentPage = 1
                    ..nextPage = 0;

                  context.read<AttUserListBloc>().add(AttUserListInitEvent(
                      teamList: _selectedTeamOpt,
                      userType: _selectedUserOpt,
                      search: "",
                      startDate: context.read<AttUserListBloc>().startDate,
                      endDate: context.read<AttUserListBloc>().endDate));

                  Navigator.pop(context1);
                },
              ),
            ),
            Expanded(
              child: ButtonFull(
                padding: const EdgeInsets.only(left: 8),
                label: R.strings.btnApply,
                backgroundColor: AppColors.filterBtnApply,
                isShadow: false,
                onTap: () {
                  List<String> strList = [];
                  strList.add(_selectedUserOpt);
                  _selectedTeamOpt.map((e) => strList.add(e.name)).toList();
                  context.read<AttUserListBloc>()
                    ..selectedUserType = _selectedUserOpt
                    ..selectedTeamOpt = _selectedTeamOpt
                    ..filterLabels = strList
                    ..currentPage = 1
                    ..nextPage = 0;

                  context.read<AttUserListBloc>().add(AttUserListInitEvent(
                      teamList: _selectedTeamOpt,
                      userType: _selectedUserOpt,
                      search: context.read<AttUserListBloc>().search,
                      startDate: context.read<AttUserListBloc>().startDate,
                      endDate: context.read<AttUserListBloc>().endDate));

                  Navigator.pop(context1);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}