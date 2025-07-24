import 'package:flutter/material.dart';

import '../../core/resources/colors.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback? onTap;
  final String? label;
  final Color? backgroundColor;
  final Color? labelColor;
  final EdgeInsetsGeometry? padding;

  const CustomButton(
      {Key? key, this.onTap, this.label, this.backgroundColor, this.labelColor, this.padding})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 16),
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.colorAccent,
          borderRadius: const BorderRadius.all(Radius.circular(10.0)),
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: Colors.grey.withOpacity(0.6),
                offset: const Offset(4, 4),
                blurRadius: 8.0),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap ?? () {},
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(
                  label ?? 'Button',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: labelColor ?? AppColors.red,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
