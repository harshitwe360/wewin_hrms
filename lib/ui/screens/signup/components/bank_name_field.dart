import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/config/config.dart';
import '../bloc/signup_bloc.dart';

class BankNameInput extends StatelessWidget {
  const BankNameInput({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignupBloc, SignupState>(
      buildWhen: (previous, current) {
        return previous.isBankNameInvalid != current.isBankNameInvalid;
      },
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 0.0),
          child: TextFormField(
            textInputAction: TextInputAction.next,
            inputFormatters: <TextInputFormatter>[
              LengthLimitingTextInputFormatter(150),
            ],
            initialValue: state.bankName,
            onChanged: (value) =>
                context.read<SignupBloc>().add(BankNameChanged(bankName: value)),
            keyboardType: TextInputType.name,
            style: TextStyle(fontSize: R.dimens.fontSizeLarge,
                color: AppColors.textDark),
            decoration: InputDecoration(
                labelText: "Bank Name",
                hintText: "Enter Bank Name",
                helperText: "",
                // fillColor: AppColors.fieldBg,
                // prefixIcon: const Icon(Icons.person, color: AppColors.textLight),
                errorText: state.isBankNameInvalid
                    ? "Invalid Bank Name."
                    : null),
          ),
        );
      },
    );
  }
}