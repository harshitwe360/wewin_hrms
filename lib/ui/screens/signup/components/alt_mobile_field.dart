import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/config/config.dart';
import '../bloc/signup_bloc.dart';

class AltMobileInput extends StatelessWidget {
  const AltMobileInput({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignupBloc, SignupState>(
      buildWhen: (previous, current) {
        return previous.isAltMobileInvalid != current.isAltMobileInvalid;
      },
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 0.0),
          child: TextFormField(
            textInputAction: TextInputAction.next,
            inputFormatters: <TextInputFormatter>[
              LengthLimitingTextInputFormatter(10),  // Limits input to 10 characters
              FilteringTextInputFormatter.digitsOnly,  // Allows only digits
            ],
            initialValue: state.altMobile,
            onChanged: (value) =>
                context.read<SignupBloc>().add(AltMobileChanged(altMobile: value)),
            keyboardType: TextInputType.number,
            style: TextStyle(fontSize: R.dimens.fontSizeLarge,
                color: AppColors.textDark),
            decoration: InputDecoration(
                labelText: "Alternate Number *",
                hintText: "Enter Alternate Number",
                helperText: "",
                // fillColor: AppColors.fieldBg,
                // prefixIcon: const Icon(Icons.phone_android, color: AppColors.textLight),
                errorText: state.isAltMobileInvalid
                    ? "Invalid Alternate Number"
                    : null),
          ),
        );
      },
    );
  }
}