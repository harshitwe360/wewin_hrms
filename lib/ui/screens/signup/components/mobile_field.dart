import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/config/config.dart';
import '../bloc/signup_bloc.dart';

class MobileInput extends StatelessWidget {
  const MobileInput({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignupBloc, SignupState>(
      buildWhen: (previous, current) {
        return previous.isMobileInvalid != current.isMobileInvalid;
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
            initialValue: state.mobile,
            onChanged: (value) =>
                context.read<SignupBloc>().add(MobileChanged(mobileNo: value)),
            keyboardType: TextInputType.number,
            style: TextStyle(fontSize: R.dimens.fontSizeLarge,
                color: AppColors.textDark),
            decoration: InputDecoration(
                labelText: "Mobile Number *",
                hintText: "Enter Mobile No.",
                helperText: "",
                // fillColor: AppColors.fieldBg,
                // prefixIcon: const Icon(Icons.phone_android, color: AppColors.textLight),
                errorText: state.isMobileInvalid
                    ? "Invalid Mobile Number"
                    : null),
          ),
        );
      },
    );
  }
}