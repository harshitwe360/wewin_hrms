import 'package:flutter/material.dart';

import '../../../../core/config/config.dart';
import 'components/attendance_view.dart';

class PunchLogScreen extends StatefulWidget {
  const PunchLogScreen({super.key});

  @override
  State<PunchLogScreen> createState() => _PunchLogScreenState();
}

class _PunchLogScreenState extends State<PunchLogScreen>
    with TickerProviderStateMixin {
  late final AnimationController? _animationController;
  final List<Widget> _widgetList = <Widget>[];

/*Future<void> onRefresh() async {
    context.read<ActivityBloc>().add(GetActivityTableData(
        filter: FilterModel(
            startDate: AppHelper.dateFormat(endDays: 6),
            endDate: AppHelper.dateFormat())
    ));
  }*/

  @override
  void initState() {
    _animationController = AnimationController(
        duration: const Duration(milliseconds: 100), vsync: this);
    // onRefresh();
    getPageListViewUI();
    super.initState();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
          slivers: <Widget>[
            ScrollableAppBar(
                title: R.strings.txtPunchLogsTitle, icon: R.icon.productivity),
            SliverPadding(
              padding: const EdgeInsets.all(0.0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, int index) {
                    _animationController?.forward();
                    return Container(child: _widgetList[index]);
                  },
                  childCount: _widgetList.length,
                ),
              ),
            ),
          ],
        ),
    );
  }

  void getPageListViewUI() {
    const int count = 1;
    _widgetList.add(AttendanceView(
        isShowLogs: true,
        animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
            parent: _animationController!,
            curve: const Interval((1 / count) * 0, 1.0,
                curve: Curves.fastOutSlowIn))),
        animationController: _animationController));
  }
}
