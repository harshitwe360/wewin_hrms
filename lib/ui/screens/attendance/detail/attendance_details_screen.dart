import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/config/config.dart';
import 'bloc/att_user_list/att_user_list_bloc.dart';
import 'bloc/calendar_cubit.dart';
import 'my_attendance.dart';
import 'team_attendance.dart';

class AttendanceDetailScreen extends StatefulWidget {
  const AttendanceDetailScreen({super.key});

  @override
  State<AttendanceDetailScreen> createState() => _AttendanceDetailScreenState();
}

class _AttendanceDetailScreenState extends State<AttendanceDetailScreen>
    with TickerProviderStateMixin {

  late final AnimationController? _animationController;
  late TabController _tabController;
  RoleType role = RoleType.employee;

  Future<void> initGetData() async {
    role = await AuthService.instance.getUserRole;
    if(role != RoleType.employee){
      // _selectedIndex = 1;
    }
  }

  @override
  void initState() {
    initGetData();
    _animationController = AnimationController(
        duration: const Duration(milliseconds: 100), vsync: this);
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _animationController?.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
          title: R.strings.txtAttnDetail, iconPath: R.icon.attendanceSvg),
      body: MultiBlocProvider(
        providers: [
          BlocProvider<CalendarCubit>(
              create: (context) => CalendarCubit()),
          BlocProvider<AttUserListBloc>(
            create: (context) => AttUserListBloc()
              ..add(AttUserListInitEvent(
                  teamList: const [],
                  startDate: AppHelper.dateFormat(),
                  endDate: AppHelper.dateFormat()))
          ),
        ],
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.symmetric(
                  horizontal: 24.0, vertical: R.dimens.panelBoxT),
              padding: const EdgeInsets.all(1.0),
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.backgroundWhite,
                borderRadius: BorderRadius.circular(
                  R.dimens.borderRadius,
                ),
              ),
              child: TabBar(
                physics: const NeverScrollableScrollPhysics(),
                controller: _tabController,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    R.dimens.borderRadius,
                  ),
                  color: AppColors.colorAccent,
                ),
                labelColor: Colors.white,
                unselectedLabelColor: AppColors.textLight,
                tabs: [
                  tabView("Team Attendance", Icons.group),
                  tabView("My Attendance", Icons.calendar_today),
                ],
              ),
            ),
            // tab bar view here
            Expanded(
              child: TabBarView(
                physics: const NeverScrollableScrollPhysics(),
                controller: _tabController,
                children: [
                  TeamAttendance(),
                  MyAttendance(animationController: _animationController)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget tabView(String title, IconData icon) {
    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16.0),
          const SizedBox(width: 4.0),
          Center(child: Text(title, style: const TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 13,
            letterSpacing: -0.1,
          ))),
        ],
      ),
    );
  }
}
