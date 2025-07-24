import 'package:flutter/material.dart';

import '../../../../../../core/apis/repository/models/punch_logs.dart';
import '../../../../../../core/config/config.dart';

class CalendarEventsItemView extends StatelessWidget {
  const CalendarEventsItemView({super.key, required this.logsItem});
  final PunchLogs logsItem;

  @override
  Widget build(BuildContext context) {
    if(logsItem.inTime.isEmpty){
      return SizedBox();
    }
    final date = AppHelper.timeStrToDateTime(logsItem.inTime, date: logsItem.attendDate);
    final date2 = logsItem.outTime.isNotEmpty
        ? AppHelper.timeStrToDateTime(logsItem.outTime, date: logsItem.attendDate)
        : null;
    return Container(
      decoration: BoxDecorationX.panelWithShadowR12,
      margin: EdgeInsets.symmetric(horizontal: R.dimens.panelBoxLR, vertical: 6.0),
      padding: const EdgeInsets.symmetric(vertical: 18.0),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Expanded(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(AppHelper.dateFormat(format: 'd MMMM y', date: date),
                  style: Theme.of(context).textTheme.smallLabel),
            ),
            VerticalIconText(
                // text: AppHelper.dateFormat(format: "hh:mm a", date: date),
                text: AppHelper.dateTimeToAMPM(sDate: date),
                icon: Icons.arrow_downward_rounded,
                style: const TextStyle(
                    color: AppColors.punchIn, fontWeight: FontWeight.bold),
                iconColor: AppColors.punchIn)
          ]),
        ),
        Expanded(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(AppHelper.dateFormat(format: 'd MMMM y', date: date2 ?? date),
                  style: Theme.of(context).textTheme.smallLabel),
            ),
            VerticalIconText(
                text: AppHelper.dateTimeToAMPM(sDate: date2, returnStr: "-"),
                style: const TextStyle(
                    color: AppColors.punchOut, fontWeight: FontWeight.bold),
                icon: Icons.arrow_upward_rounded,
                iconColor: AppColors.punchOut)
          ]),
        )
      ]),
    );
  }
}
