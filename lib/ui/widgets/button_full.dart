import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../core/theme/themes.dart';
import '../../core/resources/colors.dart';

class ButtonFull extends StatelessWidget {
  final VoidCallback? onTap;
  final String? label;
  final Color? backgroundColor;
  final Color? labelColor;
  final EdgeInsetsGeometry? padding;
  final double? height;
  final double? width;
  final double? radius;
  final bool isShadow;
  final IconData? icon;
  final String? svgPath;
  final BoxBorder? border;
  final bool isTextRight;

  const ButtonFull(
      {super.key,
      this.onTap,
      this.label,
      this.backgroundColor,
      this.labelColor,
      this.padding,
      this.height,
      this.width,
      this.radius,
      this.isShadow = true,
      this.isTextRight = true,
      this.border,
      this.svgPath,
      this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ??
          const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 16),
      child: Container(
        width: width ?? double.infinity,
        height: height ?? 55,
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.colorAccent,
          borderRadius: BorderRadius.all(Radius.circular(radius ?? 10.0)),
          border: border,
          boxShadow: isShadow
              ? <BoxShadow>[
                  BoxShadow(
                      color: Colors.grey.withOpacity(0.6),
                      offset: const Offset(4, 4),
                      blurRadius: 8.0),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            focusColor: Colors.transparent,
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,
            splashColor: Colors.grey.withOpacity(0.2),
            borderRadius: const BorderRadius.all(
              Radius.circular(4.0),
            ),
            onTap: onTap ?? () {},
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!isTextRight)
                    Text(
                      label ?? 'Button',
                      style: Theme.of(context)
                          .textTheme
                          .largeLabel
                          .copyWith(color: labelColor ?? AppColors.white),
                    ),
                  if (icon != null || svgPath != null)
                    const SizedBox(width: 15),
                  if (svgPath != null)
                    SvgPicture.asset(svgPath!,
                        width: 28,
                        height: 28,
                        colorFilter: ColorFilter.mode(
                            labelColor ?? AppColors.white, BlendMode.srcIn),
                        semanticsLabel: label),
                  if (icon != null)
                    Icon(
                      icon ?? Icons.logout,
                      color: labelColor ?? AppColors.white,
                    ),
                  if (icon != null || svgPath != null)
                    const SizedBox(width: 15),
                  if (isTextRight)
                    Text(
                      label ?? 'Button',
                      style: Theme.of(context)
                          .textTheme
                          .largeLabel
                          .copyWith(color: labelColor ?? AppColors.white),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
