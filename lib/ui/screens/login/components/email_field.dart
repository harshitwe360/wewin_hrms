import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/login_bloc.dart';
import '../../../../core/config/config.dart';
import 'login_styles.dart';

/// Work email field, shared by both login tabs (backed by LoginBloc.email).
class EmailInput extends StatefulWidget {
  const EmailInput({super.key, this.textInputAction = TextInputAction.next,
      this.onSubmitted});

  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;

  @override
  State<EmailInput> createState() => _EmailInputState();
}

class _EmailInputState extends State<EmailInput> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      // Loading/error/OTP states carry an empty form; keep the typed value.
      buildWhen: (previous, current) =>
          current.runtimeType == LoginState &&
          (previous.isEmailInvalid != current.isEmailInvalid ||
              previous.email != current.email),
      builder: (context, state) {
        // Only sync from state when it differs, so typing keeps the cursor.
        if (_controller.text != state.email) {
          _controller.text = state.email;
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LoginFieldLabel(R.strings.labelEmail),
            TextFormField(
              controller: _controller,
              textInputAction: widget.textInputAction,
              onFieldSubmitted: widget.onSubmitted,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.deny(RegExp(r"\s")),
              ],
              autocorrect: false,
              autofillHints: const [AutofillHints.email, AutofillHints.username],
              keyboardType: TextInputType.emailAddress,
              onChanged: (value) =>
                  context.read<LoginBloc>().add(EmailChanged(email: value)),
              style: LoginStyle.fieldText,
              decoration: LoginStyle.input(
                hint: R.strings.hintEmail,
                icon: Icons.mail_outline,
                errorText: state.isEmailInvalid ? R.strings.errorMsgEmail : null,
              ),
            ),
          ],
        );
      },
    );
  }
}
