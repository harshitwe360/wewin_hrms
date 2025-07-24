import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/config/config.dart';
import '../../../../core/apis/repository/models/filter_model.dart';
import 'bloc/calendar_cubit.dart';
import 'components/calendar_view.dart';
import 'components/member_name_view.dart';
import 'components/punch_hours_view.dart';

class MyAttendance extends StatefulWidget {
  const MyAttendance({super.key,
    this.animationController, this.userId, this.bgColor, this.isInnerScreen = false});

  final AnimationController? animationController;
  final String? userId;
  final bool isInnerScreen;
  final Color? bgColor;

  @override
  State<MyAttendance> createState() => _MyAttendanceState();
}

class _MyAttendanceState extends State<MyAttendance>
    with TickerProviderStateMixin {
  List<Widget> listViews = <Widget>[];

  Future<void> onRefresh() async {
    AuthService.instance.isUserActive().then((isTokenRefresh) {
      context.read<CalendarCubit>().getCalendarInitData(FilterModel(
            userId: widget.userId,
            startDate: AppHelper.firstDayOfMonth(),
            endDate: AppHelper.lastDayOfMonth()
        ));
    }, onError: (e) {
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (r) => false);
    }).catchError((handleError) {
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (r) => false);
    });
  }

  @override
  void initState() {
    addAllListData();
    onRefresh();

    super.initState();
  }

  void addAllListData() {
    const int count = 2;

    // if(widget.isInnerScreen) {
    //   listViews.add(
    //     MemberNameView(
    //       bgColor: widget.bgColor,
    //       animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
    //           parent: widget.animationController!,
    //           curve: const Interval((1 / count) * 0, 1.0,
    //               curve: Curves.fastOutSlowIn))),
    //       animationController: widget.animationController!,
    //     ),
    //   );
    // }

    listViews.add(
      CalendarView(
        userId: widget.userId,
        animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
            parent: widget.animationController!,
            curve: const Interval((1 / count) * 0, 1.0,
                curve: Curves.fastOutSlowIn))),
        animationController: widget.animationController!,
      ),
    );
    // listViews.add(
    //   PunchHoursView(
    //     animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
    //         parent: widget.animationController!,
    //         curve: const Interval((1 / count) * 1, 1.0,
    //             curve: Curves.fastOutSlowIn))),
    //     animationController: widget.animationController!,
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        SliverPadding(
          padding: const EdgeInsets.all(0.0),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, int index) {
                widget.animationController?.forward();
                return Container(child: listViews[index]);
              },
              childCount: listViews.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget getMainListViewUI() {
    return ListView.builder(
      itemCount: listViews.length,
      scrollDirection: Axis.vertical,
      itemBuilder: (BuildContext context, int index) {
        widget.animationController?.forward();
        return listViews[index];
      },
    );
  }
}
