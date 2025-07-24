import 'package:flutter/material.dart';
import '../../../../../core/config/config.dart';

class SeparatedClock extends StatelessWidget {
  const SeparatedClock({super.key, this.punchInSecCount = 0});

  final int punchInSecCount;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          getClockView(
              context, (Duration(seconds: punchInSecCount).inHours).toString()),
          Padding(
              padding: const EdgeInsets.all(6.0),
              child: Text(":", textScaler: TextScaler.noScaling,
                  style: Theme.of(context).textTheme.largeXIXValue)),
          getClockView(context,
              (Duration(seconds: punchInSecCount).inMinutes % 60).toString()),
          Padding(
              padding: const EdgeInsets.all(6.0),
              child: Text(":", textScaler: TextScaler.noScaling,
                  style: Theme.of(context).textTheme.largeXIXValue)),
          getClockView(context,
              (Duration(seconds: punchInSecCount).inSeconds % 60).toString()),
        ],
      ),
    );
  }

  Widget getClockView(BuildContext context, String time) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12),
      decoration: BoxDecorationX.panelTime,
      child: Text(AppHelper.formatInt2(string: time),
          textScaler: TextScaler.noScaling,
          style: Theme.of(context)
              .textTheme
              .largeXIXValue
              .copyWith(color: AppColors.punchButton)),
    );
  }
}
