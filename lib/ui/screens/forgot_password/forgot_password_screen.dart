import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/config/config.dart';
import '../login/components/auth_shell.dart';
import '../login/components/login_styles.dart';
import 'bloc/password_reset_cubit.dart';

/// Step 1: request a password reset link by email
/// (WinHRMS `POST /api/auth/forgot-password`).
class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key, this.email = ""});

  /// Pre-filled from the login form.
  final String email;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PasswordResetCubit(),
      child: _ForgotPasswordView(email: email),
    );
  }
}

class _ForgotPasswordView extends StatefulWidget {
  const _ForgotPasswordView({required this.email});

  final String email;

  @override
  State<_ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<_ForgotPasswordView> {
  static const int resendCooldown = 30;

  late final TextEditingController _email =
      TextEditingController(text: widget.email);
  String? _error;
  String? _sentMessage;
  String _sentTo = "";
  int _resendIn = 0;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    _email.dispose();
    super.dispose();
  }

  void _send() {
    FocusScope.of(context).unfocus();
    final err = PasswordResetCubit.emailError(_email.text);
    setState(() => _error = err);
    if (err == null) context.read<PasswordResetCubit>().sendLink(_email.text);
  }

  void _onState(BuildContext context, PasswordResetState state) {
    if (state.status == ResetStatus.success) {
      _timer?.cancel();
      setState(() {
        _sentMessage = state.message;
        _sentTo = _email.text.trim();
        _resendIn = resendCooldown;
      });
      _timer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (!mounted) return t.cancel();
        setState(() => _resendIn--);
        if (_resendIn <= 0) t.cancel();
      });
    } else if (state.status == ResetStatus.failure) {
      setState(() => _error = state.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PasswordResetCubit, PasswordResetState>(
      listener: _onState,
      builder: (context, state) {
        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: AuthShell(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                LoginHeader(
                  title: _sentMessage == null ? "Forgot password?" : "Check your email",
                  subtitle: _sentMessage == null
                      ? "Enter your work email and we'll send you a link to reset your password."
                      : "We've sent a reset link to $_sentTo.",
                ),
                LoginPanel(
                  child: AnimatedSize(
                    duration: const Duration(milliseconds: 200),
                    alignment: Alignment.topCenter,
                    child: _sentMessage == null
                        ? _form(state)
                        : _sent(state),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back, size: 18),
                  label: const Text("Back to sign in"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _form(PasswordResetState state) {
    return Column(
      key: const ValueKey("form"),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LoginFieldLabel(R.strings.labelEmail),
        TextField(
          controller: _email,
          autofocus: widget.email.isEmpty,
          enabled: !state.isLoading,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.send,
          autocorrect: false,
          autofillHints: const [AutofillHints.email],
          inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r"\s"))],
          onChanged: (_) {
            if (_error != null) setState(() => _error = null);
          },
          onSubmitted: (_) => _send(),
          style: LoginStyle.fieldText,
          decoration: LoginStyle.input(
              hint: R.strings.hintEmail,
              icon: Icons.mail_outline,
              errorText: _error),
        ),
        const SizedBox(height: 22),
        state.isLoading
            ? const _Busy()
            : LoginGradientButton(label: "Send reset link", onPressed: _send),
      ],
    );
  }

  Widget _sent(PasswordResetState state) {
    return Column(
      key: const ValueKey("sent"),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.mark_email_read_outlined,
            size: 44, color: LoginStyle.focus),
        const SizedBox(height: 12),
        Text(_sentMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: LoginStyle.label, fontSize: 14, height: 1.4)),
        const SizedBox(height: 8),
        const Text(
            "Open the link from your email, or copy it and paste it on the next screen.",
            textAlign: TextAlign.center,
            style: TextStyle(color: LoginStyle.muted, fontSize: 13, height: 1.4)),
        const SizedBox(height: 20),
        LoginGradientButton(
          label: "I have the reset link",
          onPressed: () =>
              Navigator.pushNamed(context, AppRoutes.resetPassword),
        ),
        const SizedBox(height: 8),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(_error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: LoginStyle.error, fontSize: 13)),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Didn't get it?",
                style: TextStyle(color: LoginStyle.muted, fontSize: 14)),
            TextButton(
              onPressed: state.isLoading || _resendIn > 0 ? null : _send,
              child: Text(state.isLoading
                  ? "Sending…"
                  : _resendIn > 0
                      ? "Resend in ${_resendIn}s"
                      : "Resend"),
            ),
          ],
        ),
        TextButton(
          onPressed: () => setState(() {
            _sentMessage = null;
            _error = null;
          }),
          child: const Text("Use a different email"),
        ),
      ],
    );
  }
}

class _Busy extends StatelessWidget {
  const _Busy();

  @override
  Widget build(BuildContext context) => const SizedBox(
        height: 50,
        child: Center(
            child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2.5))),
      );
}
