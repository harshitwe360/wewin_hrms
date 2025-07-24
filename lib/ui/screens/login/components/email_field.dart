import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/login_bloc.dart';
import '../../../../core/config/config.dart';

class EmailInput extends StatefulWidget {
  const EmailInput({super.key});

  @override
  State<EmailInput> createState() => _EmailInputState();
}

class _EmailInputState extends State<EmailInput> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      buildWhen: (previous, current) {
        return previous.isEmailInvalid != current.isEmailInvalid
            || previous.email != current.email;
      },
      builder: (context, state) {
        _controller.text = state.email;
        return TextFormField(
          textInputAction: TextInputAction.next,
          controller: _controller,
          // initialValue: state.email,
          readOnly: false,
          inputFormatters: <TextInputFormatter>[
            LengthLimitingTextInputFormatter(10),  // Limits input to 10 characters
            FilteringTextInputFormatter.digitsOnly,  // Allows only digits
          ],
          onChanged: (value) =>
              context.read<LoginBloc>().add(EmailChanged(email: value)),
          onTap: () {
            // if (state is MobileNumberInitial) {
              context.read<LoginBloc>().add(FetchMobileNumber());
            // }
          },
          keyboardType: TextInputType.number,
          style: TextStyle(fontSize: R.dimens.fontSizeLarge,
              color: AppColors.textDark),
          decoration: InputDecoration(
              // border: OutlineInputBorder(
              //   borderRadius: BorderRadius.circular(10.0),
              //   borderSide: const BorderSide(color: AppColors.black)
              // ),
              // enabledBorder: OutlineInputBorder(
              //   borderSide: const BorderSide(color: AppColors.colorAccent, width: 1.0),
              //   borderRadius: BorderRadius.circular(10.0),
              // ),
              // focusedBorder: OutlineInputBorder(
              //   borderSide: const BorderSide(color: AppColors.colorAccent, width: 2.0),
              //   borderRadius: BorderRadius.circular(10.0),
              // ),
              // fillColor: AppColors.white,
              // filled: true,
              // labelStyle: const TextStyle(color: AppColors.textLight),
              // hintStyle: const TextStyle(color: AppColors.textLight),
              // contentPadding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
              labelText: R.strings.labelEmail,
              hintText: R.strings.hintEmail,
              helperText: "",
              // prefixIcon: const Icon(Icons.mail, color: AppColors.black),
              // icon: const Icon(Icons.email),
              errorStyle: TextStyle(fontSize: R.dimens.fontSizeMedium),
              // errorText: state.email.isNotEmpty && state.isEmailInvalid
              errorText: state.isEmailInvalid
                  ? R.strings.errorMsgEmail
                  : null),
        );
      },
    );
  }
}