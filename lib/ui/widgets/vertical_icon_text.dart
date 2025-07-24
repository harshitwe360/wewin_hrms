import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class VerticalIconText extends StatelessWidget {
  const VerticalIconText(
      {Key? key,
      this.text,
      this.svgPath,
      this.icon,
      this.iconColor,
      this.style,
      this.size,
      this.isExpanded = false})
      : super(key: key);
  final String? text;
  final String? svgPath;
  final IconData? icon;
  final Color? iconColor;
  final TextStyle? style;
  final double? size;
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      svgPath!=null
          ? SvgPicture.asset(
                svgPath!,
                width: 16, height: 16,
                semanticsLabel: "cel-$text",
                colorFilter: iconColor !=null ? ColorFilter.mode(
                    iconColor! , BlendMode.srcIn) : null
            )
          : Icon(icon ?? Icons.watch_later_outlined,
          color: iconColor, size: size ?? 14),
      const SizedBox(width: 3),
      (isExpanded)
          ? Expanded(
              child: Text(
                text ?? "00:00:00",
                style: style,
              ),
            )
          : Text(
              text ?? "00:00:00",
              style: style,
            )
    ]);
  }
}
