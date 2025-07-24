import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/config/config.dart';

class BottomLogin extends StatelessWidget {
  const BottomLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.colorPrimary,
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: RichText(
          text: TextSpan(
            text: R.strings.txtLoginB1,
            style: Theme.of(context).textTheme.smallLabel,
            children: <TextSpan>[
              TextSpan(
                  text: R.strings.txtTndC,
                  recognizer: TapGestureRecognizer()..onTap = _launchUrl,
                  style: Theme.of(context).textTheme.smallValue.copyWith(
                      decoration: TextDecoration.underline,
                      color: AppColors.colorAccent)
              ),
              const TextSpan(text: '.'),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchUrl() async {
    if (await canLaunchUrl(Uri.parse(AppConstants.termsUrl))) {
      await launchUrl(Uri.parse(AppConstants.termsUrl),
          mode: LaunchMode.externalApplication);
    }
  }
}