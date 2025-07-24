import 'package:flutter/material.dart';
import '../../core/config/r.dart';

class LoaderView extends StatelessWidget {
  final double? height;
  final double? width;
  final Color? bgColor;
  final EdgeInsetsGeometry? margin;
  final bool isDefaultLoader;
  final Color? defaultColor;
  const LoaderView(
      {super.key, this.height, this.width, this.bgColor, this.margin,
        this.defaultColor, this.isDefaultLoader = false});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: margin,
        color: bgColor,
        height: height ?? 50.0,
        width: width ?? 50.0,
        child: SizedBox(
            height: 50,
            child: isDefaultLoader
                ? CircularProgressIndicator(color: defaultColor)
                : Image.asset(R.images.loader)
        )),
    );
  }
}
