import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/config/config.dart';
import '../login/bloc/login_bloc.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    checkToNavigate();
  }

  void checkToNavigate() async {
    // await LocalNotificationService.initialize();

    await AuthService.instance.isUserActive().then((isUserActive) async {
      if (isUserActive) {
        await AuthService.instance.getCurrentUserData().then((user) async {
          if(user.user?.emailId != null){
            refreshToken();
          } else {
            navigateToScreen(AppRoutes.login);
          }
        });
      } else {
        navigateToScreen(AppRoutes.login);
      }
    });
  }

  void refreshToken(){
    if(!mounted) return;
    context.read<LoginBloc>().add(const RefreshToken());
  }

  void navigateToScreen(String route) {
    if(!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, route, (r) => false);
  }

  /*void willDisplayUpgrade({appStoreVersion, required display,
    installedVersion, minAppVersion}) {
    if(!display) {
      Future.delayed(const Duration(milliseconds: 10), checkToNavigate);
    }
  }

  bool onPopBtnClick(){
    checkToNavigate();
    return true;
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
          alignment: Alignment.topCenter,
          children: <Widget>[
            const BackgroundScreen(),
            // UpgradeAlert(
              // upgrader: Upgrader(
                // onIgnore: onPopBtnClick,
                // onLater: onPopBtnClick,
                // onUpdate: onPopBtnClick,
                // willDisplayUpgrade: willDisplayUpgrade,
              // ),
              // child:
              SizedBox(
                height: MediaQuery.of(context).size.height,
                child: BlocListener<LoginBloc, LoginState>(
                  listener: (context, state) {
                    if(state is LoginFinishedState){
                      navigateToScreen(state.isSuccess
                          ? AppRoutes.dashboard : AppRoutes.login);
                    }
                    if(state is LoginErrorState){
                      navigateToScreen(AppRoutes.login);
                    }
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      LoaderView(),
                      /*if(_isSkip) InkWell(
                        onTap: checkToNavigate,
                        child: const Padding(
                          padding: EdgeInsets.only(top: 12, bottom: 38.0),
                          child: Text("Skip Loading", style: TextStyle(
                            color: AppColors.textLight,
                            decoration: TextDecoration.underline,
                            letterSpacing: 1,
                            // decorationThickness: 4,
                          )),
                        ),
                      )*/
                    ],
                  ),
                ),
              ),
            // ),
          ],
        ));
  }
}
