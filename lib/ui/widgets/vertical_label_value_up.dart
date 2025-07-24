import 'package:flutter/material.dart';
import '../../core/config/config.dart';

class VerticalLabelValueUp extends StatelessWidget {
  const VerticalLabelValueUp(
      {super.key,
      this.bgColor,
      required this.label,
      this.value = "",
      this.isCircleIcon = false,
      this.isCircle = false,
      this.isVerticalLine = false,
      this.icon,
      this.leftPadding = 0});

  final Color? bgColor;
  final String label;
  final String value;
  final bool isCircleIcon;
  final bool isCircle;
  final bool isVerticalLine;
  final IconData? icon;
  final double leftPadding;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        isVerticalLine
            ? Container(
                height: 35,
                width: 5,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: const BorderRadius.all(Radius.circular(4.0)),
                ),
              )
            : Container(),
        isCircle
            ? Container(
                margin: const EdgeInsets.all(4.0),
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                ),
                child: const SizedBox(height: 8, width: 8),
              )
            : Container(),
        isCircleIcon
            ? Container(
                margin: const EdgeInsets.all(4.0),
                decoration: BoxDecoration(
                  color: bgColor,
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
              )
            : Container(),
        Padding(
          padding: const EdgeInsets.all(2.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if(value.isNotEmpty)  Padding(
                padding: EdgeInsets.only(left: leftPadding, bottom: 3),
                child: Text(
                  textScaler: TextScaler.noScaling,
                  value,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.largeValue,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: leftPadding, bottom: 2),
                child: Text(
                  label,
                  textScaler: TextScaler.noScaling,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: Theme.of(context).textTheme.smallLabel,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
