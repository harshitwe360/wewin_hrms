import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/home_bloc.dart';
import '../../../../core/config/config.dart';
import 'components/attendance_view.dart';
import 'components/punch_in_logs_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.animationController});

  final AnimationController? animationController;
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final List<Widget> _widgetList = <Widget>[];

  // RoleType _role = RoleType.employee;

  Future<void> _fetchData() async {
    // _role = await AuthService.instance.getUserRole;
    _onRefresh();
    await _buildWidgetList();
    widget.animationController?.forward();
    // setState(() {});
  }
  
  Future<void> _onRefresh() async {
    AuthService.instance.isUserActive().then((isTokenRefresh) {
      context.read<HomeBloc>()
          .add(DashboardEvent(dateFilter: AppHelper.dateFormat()));
    }, onError: (e) {
      Navigator.pushNamedAndRemoveUntil(
          context, AppRoutes.login, (r) => false);
    }).catchError((handleError) {
      Navigator.pushNamedAndRemoveUntil(
          context, AppRoutes.login, (r) => false);
    });
  }

  @override
  void initState() {
    // _fetchData();
    super.initState();
  }

  Future<List<Widget>> _buildWidgetList() async {
    const int count = 1;
    _widgetList.clear();
    _widgetList.add(
      AttendanceView(
        // isShowLogs: true,
        animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
            parent: widget.animationController!,
            curve: const Interval((1 / count) * 0, 1.0,
                curve: Curves.fastOutSlowIn))),
        animationController: widget.animationController!,
      ),
    );

    _widgetList.add(
      PunchInLogsView(
        animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
            parent: widget.animationController!,
            curve: const Interval((1 / count) * 0, 1.0,
                curve: Curves.fastOutSlowIn))),
        animationController: widget.animationController!,
      ),
    );
    return _widgetList;
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => _onRefresh(),
      child: FutureBuilder(
          future: _fetchData(),
          builder: (context, snapshot) {
          return CustomScrollView(
              slivers: <Widget>[
                SliverPadding(
                  padding: const EdgeInsets.all(0.0),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate(
                        _widgetList.isNotEmpty
                            ? _widgetList
                            : [
                          const SizedBox(height: 300, child: Center(child: CircularProgressIndicator()))
                        ],
                      ),
                    )
                  /*sliver: SliverList.builder(
                    itemCount: _widgetList.length,
                    itemBuilder: (_, int index) {
                      widget.animationController?.forward();
                      return Container(child: _widgetList[index]);
                  }),*/
                ),
              ],
            );
        }
      ),
      // ),
    );
  }
}
