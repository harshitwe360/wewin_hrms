import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../../core/config/config.dart';

class ProfileLabelValueDown extends StatelessWidget {
  const ProfileLabelValueDown(
      {super.key,
      this.bgColor,
      this.iconColor,
      required this.label,
      required this.value,
      this.isCircleIcon = false,
      this.isCircle = false,
      this.isVerticalLine = false,
      this.icon,
      this.svgPath,
      this.leftPadding = 0});

  final Color? bgColor;
  final Color? iconColor;
  final String label;
  final String value;
  final bool isCircleIcon;
  final bool isCircle;
  final bool isVerticalLine;
  final IconData? icon;
  final String? svgPath;
  final double leftPadding;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecorationX.panelBorderB8,
      padding: const EdgeInsets.all(12.0),
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
      child: Row(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.all(4.0),
            decoration: const BoxDecoration(
              color: AppColors.iconBg,
              shape: BoxShape.circle,
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: svgPath!=null && svgPath!.isNotEmpty ? SvgPicture.asset(
                  svgPath!,
                  colorFilter: ColorFilter.mode(
                      iconColor ?? AppColors.colorAccent, BlendMode.srcIn),
                  semanticsLabel: label
              ) : Icon(
                icon ?? Icons.person,
                color: AppColors.black,
              ),
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(left: leftPadding, bottom: 2),
                    child: Text(
                      label,
                      textAlign: TextAlign.start,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: Theme.of(context).textTheme.smallLabel,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: leftPadding, bottom: 3),
                    child: Text(
                      value,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.start,
                      style: Theme.of(context).textTheme.largeValue,
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
