import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../core/config/config.dart';
import 'login_bg_box.dart';

/// Shared layout for auth screens, using the app's original background:
/// corner decoration, logo, and the curved light-blue shape behind the form.
class AuthShell extends StatelessWidget {
  const AuthShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            child: SvgPicture.asset(R.icon.loginDesign01,
                height: 166, excludeFromSemantics: true),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height / 3.4,
                child: Padding(
                  padding: const EdgeInsets.only(top: 35),
                  child: Container(
                    width: 120.0,
                    alignment: Alignment.center,
                    child: Image.asset(R.images.logo, fit: BoxFit.contain),
                  ),
                ),
              ),
              Expanded(
                child: CustomPaint(
                  painter: LoginBgShape(color: AppColors.colorPrimary),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
                    child: Center(
                      child: ConstrainedBox(
                        // Keeps the form readable on tablets.
                        constraints: const BoxConstraints(maxWidth: 460),
                        child: child,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
