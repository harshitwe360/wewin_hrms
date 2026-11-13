
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/login_bloc.dart';
import 'components/auth_shell.dart';
import 'components/xtnd_login.dart';
import '../../../core/config/config.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  LoginMode _mode = LoginMode.password;

  @override
  void initState() {
    super.initState();
    AuthService.instance.clearUserData();
  }

  void _onState(BuildContext context, LoginState state) {
    if (state is LoginLoadingState) {
      LoadingDialog.show(context);
    } else if (state is LoginFinishedState) {
      if (state.isSuccess) {
        Navigator.pushNamedAndRemoveUntil(
            context, AppRoutes.dashboard, (r) => false);
      } else {
        LoadingDialog.hide(context);
      }
    } else if (state is LoginOtpSentState) {
      LoadingDialog.hide(context);
    } else if (state is LoginErrorState) {
      LoadingDialog.hide(context);
      AppHelper.showSnackBar(context,
          snackBarMode: SnackBarMode.error,
          content: state.message.isEmpty
              ? R.strings.errMsgLoginInvalid
              : state.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      listener: _onState,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: AuthShell(
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(R.strings.loginTopText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: LoginStyle.title,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5)),
                const SizedBox(height: 4),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: Text(
                    _mode == LoginMode.password
                        ? R.strings.loginSubtitle
                        : R.strings.loginSubtitleOtp,
                    key: ValueKey(_mode),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: LoginStyle.muted, fontSize: 14, height: 1.4),
                  ),
                ),
                const SizedBox(height: 20),
                LoginTabbedPanel(
                  selected: _mode,
                  onChanged: (m) {
                    FocusScope.of(context).unfocus();
                    setState(() => _mode = m);
                  },
                  // Workspace is hidden for now; login always sends
                  // AppConstants.defaultTenantSlug. Re-add WorkspaceField()
                  // above the fields to show it again.
                  child: AnimatedSize(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    alignment: Alignment.topCenter,
                    child: _mode == LoginMode.password
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const EmailInput(),
                              const SizedBox(height: 14),
                              const PasswordInput(),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () => Navigator.pushNamed(
                                      context, AppRoutes.forgotPassword,
                                      arguments: context
                                          .read<LoginBloc>()
                                          .state
                                          .email
                                          .trim()),
                                  style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4, vertical: 4),
                                      minimumSize: const Size(0, 32)),
                                  child: Text(R.strings.btnForgotPassword,
                                      style: const TextStyle(
                                          color: LoginStyle.focus,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600)),
                                ),
                              ),
                              const SizedBox(height: 10),
                              const SubmitLogin(),
                            ],
                          )
                        : const OtpLoginForm(),
                  ),
                ),
                // if (Platform.isAndroid) ...[
                //   const SizedBox(height: 28),
                //   _signUpPrompt(context),
                // ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Kept for when sign-up is shown again (its call above is commented out).
  // ignore: unused_element
  Widget _signUpPrompt(BuildContext context) {
    return Column(
      children: [
        const Row(children: [
          Expanded(child: Divider(color: LoginStyle.border)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text("or",
                style: TextStyle(color: LoginStyle.muted, fontSize: 14)),
          ),
          Expanded(child: Divider(color: LoginStyle.border)),
        ]),
        const SizedBox(height: 16),
        Text.rich(
          TextSpan(
            text: "New here? ",
            style: const TextStyle(color: LoginStyle.muted, fontSize: 14),
            children: [
              TextSpan(
                text: "Create an account",
                recognizer: TapGestureRecognizer()
                  ..onTap = () => Navigator.pushNamedAndRemoveUntil(
                      context, AppRoutes.signup, (r) => false),
                style: const TextStyle(
                    color: LoginStyle.focus, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
