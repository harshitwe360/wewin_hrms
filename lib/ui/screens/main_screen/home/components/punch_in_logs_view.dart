import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../core/apis/repository/models/punch_logs.dart';
import '../../../../../core/config/config.dart';
import '../bloc/home_bloc.dart';

class PunchInLogsView extends StatelessWidget {
  const PunchInLogsView({super.key, this.animationController, this.animation});

  final AnimationController? animationController;
  final Animation<double>? animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController!,
      child: _getContentView(context),
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: animation!,
          child: Transform(
            transform: Matrix4.translationValues(
                0.0, 30 * (1.0 - animation!.value), 0.0),
            child: child,
          ),
        );
      },
    );
  }

  Widget _getContentView(BuildContext context) {
    List<PunchLogs>? punchLogs;
    return Padding(
      padding: PaddingC.boxPadding,
      child: Container(
        decoration: BoxDecorationX.panel,
        child: Column(
            children: [
              Padding(
                  padding: const EdgeInsets.only(top: 18.0, bottom: 15.0),
                  child: Text(
                    R.strings.txtPunchLogsTitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.mediumValue,
                  )),
              const Divider(color: AppColors.black26),
              BlocConsumer<HomeBloc, HomeState>(
                listener: (context, state){
                  if(state is HomeUnAuthState){
                    Navigator.pushNamedAndRemoveUntil(
                        context, AppRoutes.login, (r) => false);
                  }
                },
                builder: (context, state) {
                  if (state is HomeLoadedState) {
                    if (state.punchLogs != null && state.punchLogs?.data.isNotEmpty) {
                      punchLogs = state.punchLogs!.data as List<PunchLogs>;
                    }

                  }
                  return _dataTable(punchLogs);
                  /*return DataTable(
                      // showBottomBorder:true,
                      horizontalMargin: 0,
                      // columnSpacing: 26,
                      columns: <DataColumn>[
                        DataColumn(
                          label: Expanded(
                            child: Text(
                              R.strings.txtPunchIn,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: AppColors.colorAccent,
                                  fontWeight: FontWeight.normal,
                                  fontStyle: FontStyle.normal),
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Expanded(
                            child: Text(
                              R.strings.txtPunchOut,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: AppColors.colorAccent,
                                  fontWeight: FontWeight.normal,
                                  fontStyle: FontStyle.normal),
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Expanded(
                            child: Text(
                              R.strings.txtDuration,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: AppColors.colorAccent,
                                  fontWeight: FontWeight.normal,
                                  fontStyle: FontStyle.normal),
                            ),
                          ),
                        ),
                      ],
                      rows: getRows(punchLogs),
                  );*/
                }
              ),
            ],
          )),
    );
  }

  Widget _dataTable(List<PunchLogs>? punchLogs){
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        // showBottomBorder:true,
        horizontalMargin: 0,
        // columnSpacing: 26,
        columns: <DataColumn>[
          DataColumn(
            label: Expanded(
              child: Text(
                R.strings.txtPunchIn,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: AppColors.colorAccent,
                    fontWeight: FontWeight.normal,
                    fontStyle: FontStyle.normal),
              ),
            ),
          ),
          DataColumn(
            label: Expanded(
              child: Text(
                R.strings.txtPunchOut,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: AppColors.colorAccent,
                    fontWeight: FontWeight.normal,
                    fontStyle: FontStyle.normal),
              ),
            ),
          ),
          DataColumn(
            label: Expanded(
              child: Text(
                R.strings.txtDuration,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: AppColors.colorAccent,
                    fontWeight: FontWeight.normal,
                    fontStyle: FontStyle.normal),
              ),
            ),
          ),
        ],
        rows: getRows(punchLogs),
      ),
    );
  }

  List<DataRow> getRows(List<PunchLogs>? punchLogs) {
    List<DataRow> rows = [];
    if (punchLogs != null && punchLogs.isNotEmpty) {
      for (PunchLogs item in punchLogs) {
        int sec = 0;
        final date = AppHelper.timeStrToDateTime(item.inTime,
            date: item.attendDate).toLocal();
        final date2 = item.outTime.isNotEmpty && item.outTime != '00:00:00'
            ? AppHelper.timeStrToDateTime(item.outTime,
                          date: item.attendDate).toLocal()
            : DateTime.now();
        sec += (date2.difference(date).inSeconds);
        rows.add(DataRow(
          cells: <DataCell>[
            DataCell(VerticalIconText(
                text: DateFormat(AppConstants.dateFTime).format(date),
                style: const TextStyle(fontWeight: FontWeight.w500),
                svgPath: R.icon.punchIn,
                iconColor: AppColors.punchIn)),
            DataCell(VerticalIconText(
                text: item.outTime.isNotEmpty && item.outTime != '00:00:00'
                    ? DateFormat(AppConstants.dateFTime).format(date2)
                    : " - ",
                style: const TextStyle(fontWeight: FontWeight.w500),
                svgPath: R.icon.punchOut,
                iconColor: AppColors.punchOut)),
            DataCell(VerticalIconText(
                isExpanded: true,
                style: const TextStyle(fontWeight: FontWeight.w500),
                text: item.outTime.isNotEmpty && item.outTime != '00:00:00'
                    ? AppHelper.stringToTime(sec.toString())
                    : " - ")),
          ],
        ));
      }
    } else {
      rows.add(DataRow(
        cells: <DataCell>[
          const DataCell(Text('')),
          DataCell(Text(R.strings.msgNoRecordFound)),
          const DataCell(Text('')),
        ],
      ));
    }
    return rows;
  }
}
