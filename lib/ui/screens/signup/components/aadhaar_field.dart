import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/config/config.dart';
import '../bloc/signup_bloc.dart';

class AadhaarInput extends StatelessWidget {
  const AadhaarInput({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignupBloc, SignupState>(
      buildWhen: (previous, current) {
        return previous.isAadhaarNoInvalid != current.isAadhaarNoInvalid;
      },
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 0.0),
          child: TextFormField(
            textInputAction: TextInputAction.next,
            inputFormatters: <TextInputFormatter>[
              LengthLimitingTextInputFormatter(12),  // Limits input to 10 characters
              FilteringTextInputFormatter.digitsOnly,  // Allows only digits
            ],
            initialValue: state.aadhaarNo,
            onChanged: (value) =>
                context.read<SignupBloc>().add(AadhaarChanged(aadhaar: value)),
            keyboardType: TextInputType.number,
            style: TextStyle(fontSize: R.dimens.fontSizeLarge,
                color: AppColors.textDark),
            decoration: InputDecoration(
                labelText: "Aadhaar No. *",
                hintText: "Enter Aadhaar No.",
                helperText: "",
                // fillColor: AppColors.fieldBg,
                // prefixIcon: const Icon(Icons.credit_card, color: AppColors.textLight),
                errorText: state.isAadhaarNoInvalid
                    ? "Invalid Aadhaar No."
                    : null),
          ),
        );
      },
    );
  }
}