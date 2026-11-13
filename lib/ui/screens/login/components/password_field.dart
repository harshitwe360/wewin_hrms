import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/login_bloc.dart';
import '../../../../core/config/config.dart';
import 'login_styles.dart';

class PasswordInput extends StatefulWidget {
  const PasswordInput({super.key});

  @override
  State<PasswordInput> createState() => _PasswordInputState();
}

class _PasswordInputState extends State<PasswordInput> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      buildWhen: (previous, current) =>
          current.runtimeType == LoginState &&
          (previous.isPasswordInvalid != current.isPasswordInvalid ||
              previous.isPasswordVisible != current.isPasswordVisible),
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LoginFieldLabel(R.strings.passwordLabel),
            TextFormField(
              controller: _controller,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              onChanged: (value) => context
                  .read<LoginBloc>()
                  .add(PasswordChanged(password: value)),
              onFieldSubmitted: (_) =>
                  context.read<LoginBloc>().add(const Submitted()),
              obscureText: !state.isPasswordVisible,
              keyboardType: TextInputType.visiblePassword,
              style: LoginStyle.fieldText,
              decoration: LoginStyle.input(
                hint: R.strings.passwordHnt,
                icon: Icons.lock_outline,
                errorText:
                    state.isPasswordInvalid ? R.strings.errorMsgPwd : null,
                suffix: IconButton(
                  tooltip: state.isPasswordVisible
                      ? "Hide password" : "Show password",
                  icon: Icon(
                      state.isPasswordVisible
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: LoginStyle.icon,
                      size: 20),
                  onPressed: () =>
                      context.read<LoginBloc>().add(const IsPasswordVisible()),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
