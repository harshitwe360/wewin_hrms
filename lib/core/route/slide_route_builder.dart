import 'package:flutter/cupertino.dart';
import 'package:swipe_back_detector/swipe_back_detector.dart';

class SlideRouteBuilder extends PageRouteBuilder {
  final Widget page;
  final String? route;
  SlideRouteBuilder({required this.page, this.route})
      : super(
      pageBuilder: (
          BuildContext context,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
          ) =>
      page,
      transitionsBuilder: (
          BuildContext context,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
          Widget child,
          ) {
        var begin = const Offset(1, 0);
        var end = Offset.zero;
        var curve = Curves.ease;

        var tween = Tween(begin: begin, end: end);
        var curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: curve,
        );

        return SwipeBackDetector(
          child: SlideTransition(
              position: tween.animate(curvedAnimation),
              child: child
          ),
        );
      },
      settings: RouteSettings(name: route)
  );
}