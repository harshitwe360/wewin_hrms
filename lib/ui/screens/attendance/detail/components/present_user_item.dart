import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../../../core/apis/repository/models/team_attend_user_list.dart';
import '../../../../../../core/config/config.dart';

class PresentUserItem extends StatelessWidget {
  const PresentUserItem({super.key, required this.item, required this.index});
  final TeamAttendanceUserItem item;
  final int index;

  @override
  Widget build(BuildContext context) {

    final String name = item.name;
    final BeforeLate isOnTime = AppHelper.isBeforeOrLate(punchIn: item.punchIn);

    return InkWell(
      onTap: () => Navigator.pushNamed(context, AppRoutes.singleAttendance,
          arguments: item.userId.toString()),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: index % 2 == 0
                ? AppColors.headYellow.withValues(alpha: 0.8)
                : index % 3 == 0
                    ? AppColors.colorAccent.withValues(alpha: 0.8)
                    : AppColors.punchIn.withValues(alpha: 0.8),
            radius: 18,
            backgroundImage: item.imageUrl != null && item.imageUrl!.isNotEmpty
                ? NetworkImage("${item.imageUrl}") : null,
            child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                ? null : name.trim().isNotEmpty
                  ? Text(
                      AppHelper.getAvatarString(name),
                      style: Theme.of(context)
                          .textTheme
                          .largeXLabel
                          .copyWith(color: AppColors.white),
                    )
                  : const Icon(Icons.person), //Text
          ),
          Expanded(
              child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
            child: Text(name.trim().capitalize(),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context)
                    .textTheme
                    .largeLabel
                    .copyWith(color: AppColors.darkText)),
          )),

          if(!item.present)
            Container(
              margin: const EdgeInsets.only(right: 28.0, left: 4.0),
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  25.0,
                ),
                color: AppColors.punchOut.withValues(alpha: 0.2),
              ),
              child: Text(R.strings.txtAbsent, style: Theme.of(context).textTheme.smallLabel.copyWith(color: AppColors.punchOut)),
            ),

          if (item.present)
            Column(children: [
              SvgPicture.asset(R.icon.punchIn,
                  colorFilter: const ColorFilter.mode(
                    AppColors.colorAccent,
                    BlendMode.srcIn,
                  ), semanticsLabel: R.strings.txtPunchIn),
              const SizedBox(height: 6.0),
              SvgPicture.asset(R.icon.punchOut,
                  colorFilter: const ColorFilter.mode(
                    AppColors.punchOut,
                    BlendMode.srcIn,
                  ), semanticsLabel: R.strings.txtPunchOut),
            ]),

          if (item.present)
            SizedBox(
                width: 55.0,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(AppHelper.dateTimeToAMPM(dateStr: item.punchIn),
                          style: Theme.of(context).textTheme.smallLabel),
                      const SizedBox(height: 6.0),
                      Text(AppHelper.dateTimeToAMPM(dateStr: item.punchOut),
                          style: Theme.of(context).textTheme.smallLabel)
                    ])),

          if (item.present)
            BeforeLate.onTime != isOnTime
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: BeforeLate.before == isOnTime
                        ? SvgPicture.asset(R.icon.rabbit,
                        colorFilter: const ColorFilter.mode(
                            AppColors.punchIn, BlendMode.srcIn), semanticsLabel: R.strings.txtBefore)
                        : SvgPicture.asset(R.icon.snail,
                        colorFilter: const ColorFilter.mode(
                            AppColors.headYellow, BlendMode.srcIn),
                            // color: AppColors.headYellow,
                            semanticsLabel: R.strings.txtLate),
                  )
                : const SizedBox(width: 28.0)
        ],
      ),
    );
  }
}
