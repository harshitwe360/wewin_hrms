import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../../core/config/config.dart';

class SignupHeaderView extends StatelessWidget{
  const SignupHeaderView({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // height: MediaQuery.of(context).size.height / 4.0,
      child: Container(
        padding: EdgeInsets.only(top: 122, left: R.dimens.panelBoxLR),
        alignment: Alignment.topLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Create an account",
                textAlign: TextAlign.start,
                style: Theme.of(context).textTheme.largeXXXValue
                    .copyWith(fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w700,
                    fontSize: 26,
                    color: AppColors.black)),
            const SizedBox(height: 8),
            RichText(
              text: TextSpan(
                text: "Already have an account? ",
                style: Theme.of(context).textTheme.largeLabel
                    .copyWith(color: AppColors.colorAccent),
                children: <TextSpan>[
                  TextSpan(
                      text: "Login In",
                      recognizer: TapGestureRecognizer()..onTap =
                          () => Navigator.pushNamedAndRemoveUntil(
                          context, AppRoutes.login, (r) => false),
                      style: Theme.of(context).textTheme.largeValue.copyWith(
                          decoration: TextDecoration.underline,
                          color: AppColors.colorAccent2)
                  ),
                  // const TextSpan(text: '.'),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}