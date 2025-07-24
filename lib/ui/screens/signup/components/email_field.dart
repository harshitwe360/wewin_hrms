import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/config/config.dart';
import '../bloc/signup_bloc.dart';

class EmailInput extends StatelessWidget {
  const EmailInput({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignupBloc, SignupState>(
      buildWhen: (previous, current) {
        return previous.isEmailInvalid != current.isEmailInvalid;
      },
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 0.0),
          child: TextFormField(
            textInputAction: TextInputAction.next,
            initialValue: state.email,
            inputFormatters: <TextInputFormatter>[
              LengthLimitingTextInputFormatter(150),
            ],
            onChanged: (value) =>
                context.read<SignupBloc>().add(EmailChanged(email: value)),
            keyboardType: TextInputType.name,
            style: TextStyle(fontSize: R.dimens.fontSizeLarge,
                color: AppColors.textDark),
            decoration: InputDecoration(
                labelText: "Email",
                hintText: "Enter Email",
                helperText: "",
                // fillColor: AppColors.fieldBg,
                // prefixIcon: const Icon(Icons.email, color: AppColors.textLight),
                errorText: state.isEmailInvalid
                    ? "Invalid Email"
                    : null),
          ),
        );
      },
    );
  }
}