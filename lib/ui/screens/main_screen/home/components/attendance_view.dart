import 'package:flutter/material.dart';

import 'punch_view.dart';
import '../../../../../core/config/config.dart';

class AttendanceView extends StatefulWidget {
  final AnimationController? animationController;
  final Animation<double>? animation;
  final bool isShowLogs;

  const AttendanceView({super.key,
      this.animationController,
      this.animation,
      this.isShowLogs = false
  });

  @override
  State<AttendanceView> createState() => _AttendanceViewState();
}

class _AttendanceViewState extends State<AttendanceView> {

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.animationController!,
      child: Padding(
        padding: PaddingC.boxPadding,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 25.0),
          decoration: BoxDecorationX.panel,
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Image.asset(
                R.images.punchBG,
                // height: 60.0,
                // width: double.infinity,
                fit: BoxFit.fitWidth,
              ),
              PunchView(),
            ],
          ),
        ),
      ),
      builder: (BuildContext aContext, Widget? child) {
        return FadeTransition(
          opacity: widget.animation!,
          child: Transform(
            transform: Matrix4.translationValues(
                0.0, 30 * (1.0 - widget.animation!.value), 0.0),
            child: child,
          ),
        );
      },
    );
  }

  /*@override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.animationController!,
      child: Padding(
        padding: PaddingC.boxPadding,
        child: Container(
          decoration: BoxDecorationX.panel,
          child: Column(
            children: [
              const PunchView(),
              // widget.isShowLogs ? const PunchInLogsView() : getHeadView()
            ],
          ),
        ),
      ),
      builder: (BuildContext aContext, Widget? child) {
        return FadeTransition(
          opacity: widget.animation!,
          child: Transform(
            transform: Matrix4.translationValues(
                0.0, 30 * (1.0 - widget.animation!.value), 0.0),
            child: child,
          ),
        );
      },
    );
  }

  Widget getHeadView() {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, AppRoutes.punchLogs);
      },
      child: Container(
        padding: const EdgeInsets.all(4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(R.strings.btnViewLogs, style: Theme.of(context).textTheme.smallValue),
            const Icon(Icons.arrow_right, color: AppColors.colorAccent),
          ],
        ),
      ),
    );
  }*/
}
