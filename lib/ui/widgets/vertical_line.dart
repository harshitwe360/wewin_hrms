import 'package:flutter/material.dart';

class VerticalLine extends StatelessWidget{
  final EdgeInsetsGeometry? padding;
  final double? height;
  final double? width;
  final double? radius;
  final Color? color;
  const VerticalLine({super.key, this.color,
    this.padding, this.height, this.width, this.radius});


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.only(top: 8, bottom: 8),
      child: Container(
        height: height ?? 2,
        width: width ?? double.infinity,
        decoration: BoxDecoration(
          color: color ?? Theme.of(context).dividerColor,
          borderRadius: BorderRadius.all(Radius.circular(radius ?? 2.0)),
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