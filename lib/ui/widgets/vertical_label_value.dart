import 'package:flutter/material.dart';
import '../../core/config/config.dart';

class VerticalLabelValue extends StatelessWidget{
  const VerticalLabelValue({Key? key, this.bgColor,
  required this.label, required this.value, this.isCircleIcon = false, this.isCenterValue = false,
    this.isVerticalLine = false, this.icon, this.leftPadding = 0}) : super(key: key);

  final Color? bgColor;
  final String label;
  final String value;
  final bool isCircleIcon;
  final bool isVerticalLine;
  final bool isCenterValue;
  final IconData? icon;
  final double leftPadding;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: isCenterValue
          ? MainAxisAlignment.center : MainAxisAlignment.start,
      children: <Widget>[
        isVerticalLine ? Container(
          height: 35,
          width: 5,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: const BorderRadius.all(Radius.circular(4.0)),
          ),
        ) : Container(),
        isCircleIcon ? Container(
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
        ) : Container(),
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: isCenterValue
                ? CrossAxisAlignment.center : CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(left: leftPadding, bottom: 3),
                child: Text(
                  value,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.largeValue,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: leftPadding, bottom: 2),
                child: Text(
                  label,
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