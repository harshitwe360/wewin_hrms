import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/config/config.dart';
import '../bloc/login_bloc.dart';
import 'email_field.dart';
import 'login_styles.dart';

/// Email OTP tab: email → Send OTP → enter code → Verify & sign in.
class OtpLoginForm extends StatefulWidget {
  const OtpLoginForm({super.key});

  @override
  State<OtpLoginForm> createState() => _OtpLoginFormState();
}

class _OtpLoginFormState extends State<OtpLoginForm> {
  static const int resendCooldown = 30;

  /// 6 digits, as in the API docs (`"otp": "123456"`).
  static const int otpLength = 6;

  String _code = "";

  /// Bumped on every send so the boxes reset.
  int _boxesGeneration = 0;
  bool _sent = false;
  String _sentTo = "";

  /// Email captured when Send was tapped (bloc state is blank while loading).
  String _pendingEmail = "";
  String? _otpError;
  int _resendIn = 0;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _email => context.read<LoginBloc>().state.email.trim();

  void _send() {
    FocusScope.of(context).unfocus();
    _pendingEmail = _sent ? _sentTo : _email;
    context.read<LoginBloc>().add(SendLoginOtp(email: _pendingEmail));
  }

  void _verify() {
    final String code = _code;
    if (!RegExp('^\\d{$otpLength}\$').hasMatch(code)) {
      setState(() =>
          _otpError = "Enter the $otpLength-digit code from your email");
      return;
    }
    setState(() => _otpError = null);
    FocusScope.of(context).unfocus();
    context.read<LoginBloc>().add(VerifyLoginOtp(email: _sentTo, otp: code));
  }

  void _onSent(LoginOtpSentState state) {
    setState(() {
      _sent = true;
      _sentTo = _pendingEmail;
      _otpError = null;
      _code = "";
      _boxesGeneration++;
      _resendIn = resendCooldown;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return t.cancel();
      setState(() => _resendIn--);
      if (_resendIn <= 0) t.cancel();
    });
    AppHelper.showSnackBar(context,
        snackBarMode: SnackBarMode.success, content: state.message);
  }

  void _changeEmail() {
    _timer?.cancel();
    setState(() {
      _sent = false;
      _resendIn = 0;
      _code = "";
      _otpError = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      listenWhen: (_, c) => c is LoginOtpSentState,
      listener: (_, state) => _onSent(state as LoginOtpSentState),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: _sent ? _codeStep() : _emailStep(),
      ),
    );
  }

  Widget _emailStep() {
    return Column(
      key: const ValueKey("email"),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        EmailInput(
            textInputAction: TextInputAction.send, onSubmitted: (_) => _send()),
        const SizedBox(height: 28),
        LoginGradientButton(label: "Send OTP", onPressed: _send),
      ],
    );
  }

  Widget _codeStep() {
    return Column(
      key: const ValueKey("code"),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(children: [
          const Icon(Icons.mark_email_read_outlined,
              color: LoginStyle.success, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text.rich(TextSpan(
              style: const TextStyle(color: LoginStyle.muted, fontSize: 14),
              children: [
                const TextSpan(text: "Code sent to "),
                TextSpan(
                    text: _sentTo,
                    style: const TextStyle(
                        color: LoginStyle.title, fontWeight: FontWeight.w600)),
              ],
            )),
          ),
          TextButton(onPressed: _changeEmail, child: const Text("Change")),
        ]),
        const SizedBox(height: 16),
        const LoginFieldLabel("One-time code"),
        const SizedBox(height: 4),
        OtpBoxes(
          key: ValueKey(_boxesGeneration),
          length: otpLength,
          onChanged: (v) => setState(() {
            _code = v;
            _otpError = null;
          }),
          onCompleted: (_) => _verify(),
        ),
        if (_otpError != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(_otpError!,
                style: const TextStyle(color: LoginStyle.error, fontSize: 13)),
          ),
        const SizedBox(height: 28),
        LoginGradientButton(label: "Verify & Sign in", onPressed: _verify),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Didn't get the code?",
                style: TextStyle(color: LoginStyle.muted, fontSize: 14)),
            TextButton(
              onPressed: _resendIn > 0 ? null : _send,
              child: Text(_resendIn > 0 ? "Resend in ${_resendIn}s" : "Resend"),
            ),
          ],
        ),
      ],
    );
  }
}
