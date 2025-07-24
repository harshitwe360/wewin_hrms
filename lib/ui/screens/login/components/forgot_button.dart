import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/config/config.dart';

class ForgotPasswordBtn extends StatelessWidget {
  const ForgotPasswordBtn({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment.topRight,
        child: TextButton(
          onPressed: _launchUrl,
          child: Text(R.strings.btnForgotPassword,
              style: Theme.of(context).textTheme.mediumLabel
                  .copyWith(color: Colors.red)
              ),
        ));
  }

  Future<void> _launchUrl() async {
    if (await canLaunchUrl(Uri.parse(AppConstants.forgotPasswordUrl))) {
      await launchUrl(Uri.parse(AppConstants.forgotPasswordUrl),
          mode: LaunchMode.externalApplication);
    }
  }
}
