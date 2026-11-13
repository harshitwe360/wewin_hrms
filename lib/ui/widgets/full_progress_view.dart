import 'package:flutter/material.dart';

import '../../core/config/config.dart';

class FullProgressBar extends StatelessWidget {
  const FullProgressBar(
      {super.key,
      required this.percent, this.fillColor, this.padding});

  final double percent;
  final Color? fillColor;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.all(8),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 20),
        width: double.infinity,
        height: 44,
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(80)),
          child: LinearProgressIndicator(
            value: (percent / 100 ), //0.05,
            valueColor: AlwaysStoppedAnimation<Color>(fillColor ?? AppColors.colorAccent),
            backgroundColor: AppColors.graphBgBar.withValues(alpha: 0.2),
          ),
        ),
      ),
    );
  }
}
