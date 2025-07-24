import 'package:flutter/material.dart';

class RequiredMarkView extends StatelessWidget{
  const RequiredMarkView({super.key,
    this.width, this.height, required this.child});

  final double? width;
  final double? height;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Container(
          margin: EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              border: const Border(
                left: BorderSide(color: Colors.red, width: 2.0),
                // right: BorderSide(color: Colors.red,width: 0)
              ),
              borderRadius: BorderRadius.circular(6.0),
            ),
            child: SizedBox(width: width ?? 8, height: height ?? 48,)
        ),
      ],
    );
  }
}