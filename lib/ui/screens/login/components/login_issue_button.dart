import 'package:flutter/material.dart';
import '../../../../core/config/config.dart';

class LoginIssueBtn extends StatelessWidget {
  const LoginIssueBtn({super.key, this.onPressed});

  final Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment.topRight,
        child: TextButton(
          onPressed: onPressed,
          child: Text("Facing login issue?",
              style: Theme.of(context).textTheme.mediumLabel
                  .copyWith(
                  // decorationThickness: 2,
                  // decorationColor: AppColors.red,
                  // decoration: TextDecoration.underline,
                  color: AppColors.red
              )),
        ));
  }
}
