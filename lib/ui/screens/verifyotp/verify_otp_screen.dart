import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/config/config.dart';
import '../login/components/auth_shell.dart';
import '../login/components/login_styles.dart';
import 'bloc/verify_otp_bloc.dart';

/// Signup step 2: verify the mobile number with the SMS code
/// (legacy signup API). Styled like the login screen.
class VerifyOtpScreen extends StatelessWidget {
  const VerifyOtpScreen({super.key, this.arguments});
  final Map<String, dynamic>? arguments;

  @override
  Widget build(BuildContext context) {
    final String mobileNo = (arguments?['mobileNo'] ?? '').toString();
    return BlocProvider(
      create: (_) =>
          VerifyOtpBloc()..add(OtpResendRequested(mobileNo: mobileNo)),
      child: _VerifyOtpBody(mobileNo: mobileNo),
    );
  }
}

class _VerifyOtpBody extends StatefulWidget {
  const _VerifyOtpBody({required this.mobileNo});

  final String mobileNo;

  @override
  State<_VerifyOtpBody> createState() => _VerifyOtpBodyState();
}

class _VerifyOtpBodyState extends State<_VerifyOtpBody> {
  void _submit() {
    FocusScope.of(context).unfocus();
    context.read<VerifyOtpBloc>().add(OtpSubmitted(mobileNo: widget.mobileNo));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<VerifyOtpBloc, VerifyOtpState>(
      listenWhen: (p, c) =>
          p.isSubmitting != c.isSubmitting ||
          (c.error != null && p.error != c.error) ||
          (c.codeSent && !p.codeSent),
      listener: _onState,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: AuthShell(child: _form()),
      ),
    );
  }

  void _onState(BuildContext context, VerifyOtpState state) {
    if (state.isSubmitting) {
      LoadingDialog.show(context);
      return;
    }
    LoadingDialog.hide(context);
    if (state.isSuccess) {
      AppHelper.showSnackBar(context,
          snackBarMode: SnackBarMode.success,
          content: 'Congratulations! Your account has been created.\n'
              'Your ID and password will be delivered shortly.');
      Navigator.pushNamedAndRemoveUntil(
          context, AppRoutes.login, (r) => false);
    } else if (state.error != null) {
      AppHelper.showSnackBar(context,
          snackBarMode: SnackBarMode.error, content: state.error!);
    } else if (state.codeSent) {
      AppHelper.showSnackBar(context,
          snackBarMode: SnackBarMode.success,
          content: 'Code sent to +91 ${widget.mobileNo}');
    }
  }

  Widget _form() {
    return BlocBuilder<VerifyOtpBloc, VerifyOtpState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text("Verify your number",
                style: TextStyle(
                    color: LoginStyle.title,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5)),
            const SizedBox(height: 8),
            Text.rich(TextSpan(
              style: const TextStyle(
                  color: LoginStyle.muted, fontSize: 14, height: 1.4),
              children: [
                const TextSpan(text: "Enter the code we sent by SMS to "),
                TextSpan(
                    text: "+91\u00A0${widget.mobileNo}", // keep number on one line
                    style: const TextStyle(
                        color: LoginStyle.title, fontWeight: FontWeight.w600)),
                const TextSpan(text: "."),
              ],
            )),
            const SizedBox(height: 28),
            const LoginFieldLabel("Verification code"),
            const SizedBox(height: 4),
            OtpBoxes(
              length: VerifyOtpBloc.codeLength,
              onChanged: (v) =>
                  context.read<VerifyOtpBloc>().add(OtpCodeChanged(v)),
            ),
            const SizedBox(height: 28),
            LoginGradientButton(
              label: "Verify",
              onPressed: state.isValid && !state.isSubmitting ? _submit : null,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Didn't get the code?",
                    style: TextStyle(color: LoginStyle.muted, fontSize: 14)),
                TextButton(
                  onPressed: state.canResend
                      ? () => context
                          .read<VerifyOtpBloc>()
                          .add(OtpResendRequested(mobileNo: widget.mobileNo))
                      : null,
                  child: Text(state.isSending
                      ? "Sending…"
                      : state.timer > 0
                          ? "Resend in ${state.timer}s"
                          : "Resend"),
                ),
              ],
            ),
            TextButton(
              onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context, AppRoutes.login, (r) => false),
              child: const Text("Back to sign in"),
            ),
          ],
        );
      },
    );
  }
}
