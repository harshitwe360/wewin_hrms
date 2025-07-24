import 'package:flutter/cupertino.dart';

class LoginBgShape extends CustomPainter {
  LoginBgShape({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    var path = Path();
    path.moveTo(0,size.height);
    path.lineTo(0,size.height*0.1295983);
    path.cubicTo(size.width*0.2202778,size.height*0.04418605,size.width*0.4638889,size.height*-0.0002114165,size.width*0.7111111,0);
    path.cubicTo(size.width*0.8080556,0,size.width*0.9047222,size.height*0.006765328,size.width,size.height*0.02029598);
    path.lineTo(size.width,size.height);
    path.lineTo(0,size.height);
    path.close();

    /*path.moveTo(size.width,size.height);
    path.lineTo(size.width,size.height*0.1296406);
    path.arcToPoint(Offset(size.width*0.2888889,0),radius: Radius.elliptical(size.width*1.559833, size.height*1.187188),rotation: 0 ,largeArc: false,clockwise: false);
    path.arcToPoint(Offset(0,size.height*0.02025370),radius: Radius.elliptical(size.width*1.576278, size.height*1.199704),rotation: 0 ,largeArc: false,clockwise: false);
    path.lineTo(0,size.height);
    path.close();*/

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate)  => false;
}