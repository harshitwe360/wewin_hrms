import 'package:flutter/material.dart';
import '../../core/config/config.dart';

class HorizontalLabelValue extends StatelessWidget{
  const HorizontalLabelValue({super.key, this.bgColor, this.iconBgColor,
  required this.label, required this.value, this.isCircleIcon = false,
    this.icon, this.leftPadding = 0, this.padding, this.margin});

  final Color? bgColor;
  final Color? iconBgColor;
  final String label;
  final String value;
  final bool isCircleIcon;
  final IconData? icon;
  final double leftPadding;
  final EdgeInsets? padding;
  final EdgeInsets? margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.all(Radius.circular(4.0)),
      ),
      child: Row(
        children: <Widget>[
          isCircleIcon ? Container(
            margin: const EdgeInsets.only(top: 4.0, left: 4.0, bottom: 4.0, right: 9.0),
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Icon(
                icon ?? Icons.person,
                color: AppColors.spacer,
                size: 14,
              ),
            ),
          ) : Container(),
          Expanded(
            child: Text(
              label,
              textAlign: TextAlign.start,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: Theme.of(context).textTheme.mediumLabel,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(6.0),
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.largeValue,
            ),
          ),
        ],
      ),
    );
  }

}