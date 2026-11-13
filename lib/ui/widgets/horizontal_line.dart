import 'package:flutter/material.dart';

class HorizontalLine extends StatelessWidget{
  final EdgeInsetsGeometry? padding;
  final double? height;
  const HorizontalLine({super.key, this.padding, this.height});


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.only(top: 8, bottom: 8),
      //padding: const EdgeInsets.only(left: 24, right: 24, top: 8, bottom: 0),
      child: Container(
        height: height ?? 2,
        decoration: BoxDecoration(
          color: Theme.of(context).dividerColor,
          borderRadius: const BorderRadius.all(Radius.circular(2.0)),
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
                offset: const Offset(1.1, 1.1),
                blurRadius: 10.0),
          ],
        ),
      ),
    );
  }
}