import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'components/login_bg_box.dart';
import 'bloc/login_bloc.dart';
import 'components/xtnd_login.dart';
import '../../../core/config/config.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    AuthService.instance.clearUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Stack(
        children: [
          Positioned(
              top: 0,
              left: 0,
              child: SvgPicture.asset(
                  R.icon.loginDesign01, height: 166,
                  semanticsLabel: R.strings.btnFilter
              )),
          _pageContainer(context),
        ],
      ),
    );
  }

  Widget _pageContainer(BuildContext context) {
    return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height / 3.4,
                child: Padding(
                  padding: EdgeInsets.only(top: 35),
                  child: Container(
                    width: 120.0,
                    alignment: Alignment.center,
                    child: Image.asset(
                      R.images.logo,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              BlocListener<LoginBloc, LoginState>(
                listener: (context, state) {
                  if (state is LoginLoadingState) {
                    LoadingDialog.show(context);
                  }

                  if (state is LoginFinishedState) {
                    if (state.isSuccess) {
                      Navigator.pushNamedAndRemoveUntil(
                          context, AppRoutes.dashboard, (r) => false);
                    } else {
                      LoadingDialog.hide(context);
                    }
                  } else if (state is LoginErrorState) {
                    // API error message show here
                    LoadingDialog.hide(context);
                    AppHelper.showSnackBar(context,
                        snackBarMode: SnackBarMode.error,
                        content: state.message.isEmpty ? R.strings.errMsgLoginInvalid : state.message);
                  }
                },
                child: _loginForm(),
              ),
              // const BottomLogin(),
            ]);
  }

  Widget _loginForm() {
    return Expanded(
      child: CustomPaint(
        painter: LoginBgShape(color:AppColors.colorPrimary),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.only(
                left: 40.0, right: 40.0, top: 33.0, bottom: 0.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(R.strings.loginTopText,
                      style: Theme.of(context).textTheme.largeXXXValue
                          .copyWith(color: AppColors.black, fontSize: 28)),
                const SizedBox(height: 46),
                const EmailInput(),
                const Stack(
                  children: [
                    PasswordInput(),
                    Padding(
                      padding: EdgeInsets.only(top: 48, bottom: 18),
                        child: Text(".")
                        // child: ForgotPasswordBtn()
                    ),
                  ],
                ),
                const SubmitLogin(),
                if (Platform.isAndroid)
                  const SizedBox(height: 38),
                if (Platform.isAndroid)
                  Text("or", style: Theme.of(context).textTheme.smallLabel),
                if (Platform.isAndroid)
                  const SizedBox(height: 38),
                if (Platform.isAndroid)
                  RichText(
                  text: TextSpan(
                    text: "Are you new? ",
                    style: Theme.of(context).textTheme.largeLabel,
                    children: <TextSpan>[
                      TextSpan(
                          text: "Sign up here",
                          recognizer: TapGestureRecognizer()..onTap =
                              () => Navigator.pushNamedAndRemoveUntil(
                                  context, AppRoutes.signup, (r) => false),
                          style: Theme.of(context).textTheme.largeValue.copyWith(
                              decoration: TextDecoration.underline,
                              color: AppColors.black)
                      ),
                      const TextSpan(text: '.'),
                    ],
                  ),
                ),
                const SizedBox(height: 33)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
