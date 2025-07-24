import 'package:flutter/material.dart';

import '../../core/resources/colors.dart';

class ButtonShort extends StatelessWidget {
  final VoidCallback? onTap;
  final String? label;
  final Color? backgroundColor;
  final Color? labelColor;
  final EdgeInsetsGeometry? padding;

  const ButtonShort(
      {super.key, this.onTap, this.label, this.backgroundColor, this.labelColor, this.padding});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.only(top: 20.0, bottom: 20.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: labelColor ?? AppColors.white,
          backgroundColor: backgroundColor ?? AppColors.colorAccent,
          minimumSize: const Size(160, 36),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
        ),
        onPressed: onTap ?? () {},
        child: Text(label ?? 'Button',),
      ),
    );
  }
}
