import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/config/config.dart';
import '../login/components/auth_shell.dart';
import '../login/components/login_styles.dart';
import 'bloc/password_reset_cubit.dart';

/// Step 2: set a new password with the emailed reset link/token
/// (WinHRMS `POST /api/auth/reset-password`).
class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key, this.tokenOrLink = ""});

  /// Optional pre-filled link or token.
  final String tokenOrLink;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PasswordResetCubit(),
      child: _ResetPasswordView(tokenOrLink: tokenOrLink),
    );
  }
}

class _ResetPasswordView extends StatefulWidget {
  const _ResetPasswordView({required this.tokenOrLink});

  final String tokenOrLink;

  @override
  State<_ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<_ResetPasswordView> {
  late final TextEditingController _link =
      TextEditingController(text: widget.tokenOrLink);
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirm = TextEditingController();
  bool _showPassword = false;
  String? _linkError;
  String? _passwordError;
  String? _confirmError;
  String? _serverError;

  @override
  void dispose() {
    _link.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text?.trim() ?? "";
    if (text.isEmpty) return;
    setState(() {
      _link.text = text;
      _linkError = null;
    });
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    setState(() {
      _serverError = null;
      _linkError = PasswordResetCubit.tokenError(_link.text);
      _passwordError = PasswordResetCubit.passwordError(_password.text);
      _confirmError = _confirm.text != _password.text
          ? "Passwords don't match."
          : null;
    });
    if (_linkError != null || _passwordError != null || _confirmError != null) {
      return;
    }
    context
        .read<PasswordResetCubit>()
        .reset(tokenOrLink: _link.text, password: _password.text);
  }

  void _onState(BuildContext context, PasswordResetState state) {
    if (state.status == ResetStatus.success) {
      AppHelper.showSnackBar(context,
          snackBarMode: SnackBarMode.success,
          content: state.message ?? "Password updated. You can now log in.");
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (r) => false);
    } else if (state.status == ResetStatus.failure) {
      setState(() => _serverError = state.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PasswordResetCubit, PasswordResetState>(
      listener: _onState,
      builder: (context, state) {
        final bool busy = state.isLoading;
        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: AuthShell(
            child: AutofillGroup(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const LoginHeader(
                    title: "Set a new password",
                    subtitle:
                        "Paste the reset link from your email, then choose a new password.",
                  ),
                  LoginPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const LoginFieldLabel("Reset link"),
                        TextField(
                          controller: _link,
                          enabled: !busy,
                          autocorrect: false,
                          keyboardType: TextInputType.url,
                          textInputAction: TextInputAction.next,
                          onChanged: (_) {
                            if (_linkError != null) setState(() => _linkError = null);
                          },
                          style: LoginStyle.fieldText,
                          decoration: LoginStyle.input(
                            hint: "Paste link or token",
                            icon: Icons.link,
                            errorText: _linkError,
                            suffix: IconButton(
                              tooltip: "Paste",
                              onPressed: busy ? null : _paste,
                              icon: const Icon(Icons.content_paste,
                                  size: 20, color: LoginStyle.icon),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        const LoginFieldLabel("New password"),
                        TextField(
                          controller: _password,
                          enabled: !busy,
                          obscureText: !_showPassword,
                          autofillHints: const [AutofillHints.newPassword],
                          textInputAction: TextInputAction.next,
                          onChanged: (_) {
                            if (_passwordError != null) {
                              setState(() => _passwordError = null);
                            }
                          },
                          style: LoginStyle.fieldText,
                          decoration: LoginStyle.input(
                            hint: "At least ${PasswordResetCubit.minPassword} characters",
                            icon: Icons.lock_outline,
                            errorText: _passwordError,
                            suffix: IconButton(
                              tooltip: _showPassword ? "Hide password" : "Show password",
                              onPressed: () =>
                                  setState(() => _showPassword = !_showPassword),
                              icon: Icon(
                                  _showPassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  size: 20,
                                  color: LoginStyle.icon),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        const LoginFieldLabel("Confirm password"),
                        TextField(
                          controller: _confirm,
                          enabled: !busy,
                          obscureText: !_showPassword,
                          autofillHints: const [AutofillHints.newPassword],
                          textInputAction: TextInputAction.done,
                          onChanged: (_) {
                            if (_confirmError != null) {
                              setState(() => _confirmError = null);
                            }
                          },
                          onSubmitted: (_) => _submit(),
                          style: LoginStyle.fieldText,
                          decoration: LoginStyle.input(
                            hint: "Re-enter new password",
                            icon: Icons.lock_reset,
                            errorText: _confirmError,
                          ),
                        ),
                        if (_serverError != null) ...[
                          const SizedBox(height: 12),
                          Text(_serverError!,
                              style: const TextStyle(
                                  color: LoginStyle.error, fontSize: 13)),
                        ],
                        const SizedBox(height: 22),
                        busy
                            ? const SizedBox(
                                height: 50,
                                child: Center(
                                    child: SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2.5))))
                            : LoginGradientButton(
                                label: "Update password", onPressed: _submit),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: busy
                        ? null
                        : () => Navigator.pushNamedAndRemoveUntil(
                            context, AppRoutes.login, (r) => false),
                    child: const Text("Back to sign in"),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
