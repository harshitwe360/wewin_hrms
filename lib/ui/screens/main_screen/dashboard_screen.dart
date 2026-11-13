import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import '../../../core/apis/repository/models/auth_response.dart';
import '../attendance/single_attendance.dart';
import 'home/bloc/home_bloc.dart';
import '../../../core/config/config.dart';
import 'home/home.dart';
import 'profile/profile.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  AnimationController? animationController;
  int _selectedIndex = 1;
  String title = R.strings.txtHome;
  IconData titleIcon = Icons.home_outlined;
  String? iconPath = R.icon.homeDark;
  late Widget tabBody;
  RoleType role = RoleType.employee;
  AuthResponse auth = AuthResponse();

  AppLifecycleState? _lastLifecycleState;
  bool isAppResumed = false;

  Future<void> initGetData() async {

    WidgetsBinding.instance.addObserver(this);
    _lastLifecycleState = AppLifecycleState.resumed;

    role = await AuthService.instance.getUserRole;
    auth = await AuthService.instance.getCurrentUserData();


    // App Usage code here -
    /*DateTime endDate = DateTime.now();
    DateTime startDate = DateTime(endDate.year, endDate.month, endDate.day);
    AppsUsage.getUsage(startDate, endDate);*/

    try {
      await AuthService.instance.isUserActive();
      if (!mounted) return;
      context
          .read<HomeBloc>()
          .add(DashboardEvent(dateFilter: AppHelper.dateFormat()));
    } catch (_) {
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (r) => false);
      return;
    }
    setState(() {});
  }

  @override
  void initState() {
    initGetData();
    animationController = AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this);
    tabBody = HomeScreen(animationController: animationController);
    super.initState();
  }

  @override
  void dispose() {
    animationController?.dispose();
    WidgetsBinding.instance.removeObserver(this); // clean up observer
    super.dispose();
  }

  /// This method listens to lifecycle changes
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _lastLifecycleState != AppLifecycleState.resumed) {
      _onAppResume();
    } else if (state == AppLifecycleState.paused) {
      isAppResumed = false; // Reset the flag when the app is paused (goes to the background)
    }
    _lastLifecycleState = state;
  }

  void _onAppResume() {
    if (isAppResumed) {
      return; // Skip if already resumed
    }
    isAppResumed = true;
    context.read<HomeBloc>().add(PunchLogsEvent(dateFilter: AppHelper.dateFormat()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
          appBar: CustomAppBar(title:title, icon:titleIcon, iconPath:iconPath),
          body: tabBody,
          bottomNavigationBar: ClipRRect(
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(10),
              topLeft: Radius.circular(10),
            ),
            child: BottomNavigationBar(
              elevation: 12,
              selectedItemColor: AppColors.colorAccent2,
              items: <BottomNavigationBarItem>[
                getBottomBarItemUI(title: R.strings.txtProfile,
                    svgPath: R.icon.userDark),
                getBottomBarItemUI(title: R.strings.txtHome,
                    svgPath: R.icon.homeDark),
                getBottomBarItemUI(title: R.strings.txtAttendance,
                    svgPath: R.icon.attendanceDark),
                /*getBottomBarItemUI(title: R.strings.txtNavigator,
                    svgPath: R.icon.menu),*/
              ],
              currentIndex: _selectedIndex,
              onTap: _onButtonNavItemTapped,
            ),
          ),
        );
  }

  BottomNavigationBarItem getBottomBarItemUI(
      {required String title, required String svgPath}){
    return BottomNavigationBarItem(
      icon: SvgPicture.asset(
          svgPath,
          width: 36,
          height: 36,
          semanticsLabel: title
      ),
      activeIcon: SvgPicture.asset(
          svgPath,
          width: 36,
          height: 36,
          semanticsLabel: title,
          colorFilter: const ColorFilter.mode(
              AppColors.colorAccent2, BlendMode.srcIn)
      ),
      label: title,
    );
  }

  void _onButtonNavItemTapped(int index) {
    animationController?.reverse().then<dynamic>((data) {
      if (!mounted) return;

      setState(() {
        _selectedIndex = index;
        if (index == 0) {
          title = R.strings.txtProfile;
          titleIcon = Icons.person;
          iconPath = R.icon.userDark;
          tabBody = const Profile();
        } else if (index == 1) {
          title = R.strings.txtHome;
          titleIcon = Icons.home_outlined;
          iconPath = R.icon.homeDark;
          tabBody = HomeScreen(animationController: animationController);
        } else if (index == 2) {
          title = R.strings.txtAttendance;
          titleIcon = Icons.calendar_month;
          iconPath = R.icon.attendanceDark;
          tabBody = SingleAttendance(userId: auth.user?.userId ?? "0"); // MenuScreen(auth: auth, role: role);
        /*} else if (index == 3) {
          title = R.strings.txtNavigator;
          titleIcon = Icons.menu_outlined;
          iconPath = R.icon.menu;
          tabBody = MenuScreen(auth: auth, role: role);*/
        }
      });
    });
  }
}
