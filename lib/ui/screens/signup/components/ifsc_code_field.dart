import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/config/config.dart';
import '../bloc/signup_bloc.dart';

class IfscCodeInput extends StatelessWidget {
  const IfscCodeInput({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignupBloc, SignupState>(
      buildWhen: (previous, current) {
        return previous.isIfscCodeInvalid != current.isIfscCodeInvalid;
      },
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 0.0),
          child: TextFormField(
            textInputAction: TextInputAction.next,
            inputFormatters: <TextInputFormatter>[
              LengthLimitingTextInputFormatter(11),
            ],
            initialValue: state.ifscCode,
            onChanged: (value) =>
                context.read<SignupBloc>().add(IfscCodeChanged(ifscCode: value)),
            keyboardType: TextInputType.name,
            style: TextStyle(fontSize: R.dimens.fontSizeLarge,
                color: AppColors.textDark),
            decoration: InputDecoration(
                labelText: "IFSC Code",
                hintText: "Enter IFSC Code",
                helperText: "",
                // fillColor: AppColors.fieldBg,
                // prefixIcon: const Icon(Icons.person, color: AppColors.textLight),
                errorText: state.isIfscCodeInvalid
                    ? "Invalid IFSC Code."
                    : null),
          ),
        );
      },
    );
  }
}