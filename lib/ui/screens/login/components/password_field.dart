import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/login_bloc.dart';
import '../../../../core/config/config.dart';

class PasswordInput extends StatelessWidget {
  const PasswordInput({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: ThemeData().colorScheme.copyWith(
          onSurface: AppColors.white,
        ),
      ),
      child: BlocBuilder<LoginBloc, LoginState>(
        buildWhen: (previous, current) =>
            (previous.isPasswordInvalid != current.isPasswordInvalid ||
                previous.isPasswordVisible != current.isPasswordVisible),
        builder: (context, state) {
          return TextFormField(
            textInputAction: TextInputAction.done,
            initialValue: state.password,
            onChanged: (value) =>
                context.read<LoginBloc>().add(PasswordChanged(password: value)),
            obscureText: !state.isPasswordVisible,
            keyboardType: TextInputType.text,
            style: TextStyle(fontSize: R.dimens.fontSizeLarge,
                color: AppColors.textDark),
            decoration: InputDecoration(
              // border: OutlineInputBorder(
              //     borderRadius: BorderRadius.circular(10.0),
              //     borderSide: const BorderSide(color: AppColors.black)
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
              labelText: R.strings.passwordLabel,
              hintText: R.strings.passwordHnt,
              helperText: '',
              // prefixIconColor: AppColors.white,
              // prefixIcon: const Icon(Icons.lock, color: AppColors.white),
              suffixIcon: IconButton(
                // icon: Icon(Icons.remove_red_eye),
                icon: state.isPasswordVisible
                    ? const Icon(Icons.visibility, color: AppColors.black)
                    : const Icon(Icons.visibility_off, color: AppColors.black),
                onPressed: () => {
                  print("Icon Pressed"),
                  context.read<LoginBloc>().add(const IsPasswordVisible())
                },
              ),
              errorStyle: TextStyle(fontSize: R.dimens.fontSizeMedium),
              // errorText: state.password.isNotEmpty && state.isPasswordInvalid
              errorText: state.isPasswordInvalid ? R.strings.errorMsgPwd : null,
            ),
          );
        },
      ),
    );
  }
}
