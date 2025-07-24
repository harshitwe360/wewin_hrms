import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import '../../../core/config/config.dart';
import '../login/components/login_bg_box.dart';
import 'bloc/signup_bloc.dart';
import 'components/xtnd_signup.dart';

class SignupScreen extends StatefulWidget{
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => SignupBloc()..add(LoadInitData()),
        child: Stack(
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
      ),
    );
  }

  Widget _pageContainer(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SignupHeaderView(),
          BlocListener<SignupBloc, SignupState>(
            listener: (context, state) {
              if (state is SignupLoadingState) {
                LoadingDialog.show(context);
              }
              if (state is SignupFinishedState) {
                LoadingDialog.hide(context);
                if (state.isSuccess) {
                  Navigator.pushNamedAndRemoveUntil(context,
                      AppRoutes.verifyOTP,
                      arguments: {"mobileNo": state.mobileNo},
                          (r) => false);
                }
              } else if (state is SignupErrorState) {
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
                left: 32.0, right: 32.0, top: 0.0, bottom: 0.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 46),
                const RequiredMarkView(child: NameInput()),
                const RequiredMarkView(child: MobileInput()),
                const RequiredMarkView(child: AltMobileInput()),
                const RequiredMarkView(child: LocationDropDown()),
                const RequiredMarkView(child: ProcessDropDown()),
                const EmailInput(),
                const AadhaarInput(),
                const BankNameInput(),
                const BankAccountInput(),
                const BankBranchInput(),
                const IfscCodeInput(),

                const SubmitLogin(),
                const SizedBox(height: 33)
              ],
            ),
          ),
        ),
      ),
    );
  }
}