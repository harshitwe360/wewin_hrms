import 'package:flutter/material.dart';
import '../../core/config/config.dart';

class VerticalLineLabel extends StatelessWidget{
  const VerticalLineLabel({Key? key, this.bgColor,
  required this.label, this.leftPadding = 0}) : super(key: key);

  final Color? bgColor;
  final String label;
  final double leftPadding;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          height: 12,
          width: 3,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: const BorderRadius.all(Radius.circular(4.0)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left:5.0, right: 5, top: 5, bottom: 7),
          child: Text(
            label,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            style: Theme.of(context).textTheme.smallLabel,
          ),
        )
      ],
    );
  }

}