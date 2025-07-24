import 'dart:math';
import 'package:flutter/material.dart';

import '../../../../../core/config/config.dart';

class PresencePieChart extends StatelessWidget {
  const PresencePieChart({super.key, required this.presentData});
  final dynamic presentData;

  @override
  Widget build(BuildContext context) {
    final double presentPercent = presentData.todayPresentPercent;
    final double absentPercent = ((presentPercent.round()) - 98).abs().toDouble();

    return Container(
      height: 120.0,
      width: 120.0,
      decoration: const BoxDecoration(shape: BoxShape.circle),
      child: Center(
        // Container of the pie chart
        child: Container(
          height: 125.0,
          width: 125.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.shadow.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 2,
                offset: const Offset(0, 2), // changes position of shadow
              ),
            ],
          ),
          child: Stack(
            children: <Widget>[
              Center(
                  child: MiddleRing(
                width: 320.0,
                innerContent: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("${presentData.totalUsers ?? 0}",
                        style: Theme.of(context).textTheme.largeValue),
                    Text(R.strings.txtTotal,
                        style: Theme.of(context).textTheme.smallLabel),
                  ],
                ),
              )),
              CustomPaint(
                painter: ProgressRings(
                  startAfterPercent: presentPercent + 1,
                  percentValue: absentPercent,
                  colors: AppColors.grey600,
                ),
                child: const Center(),
              ),
              CustomPaint(
                painter: ProgressRings(
                  startAfterPercent: 0,
                  percentValue: presentPercent,
                  colors: AppColors.headYellow,
                ),
                child: const Center(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MiddleRing extends StatelessWidget {
  final num width;
  final Widget innerContent;

  const MiddleRing({Key? key, required this.width, required this.innerContent})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: width.toDouble(),
      width: width.toDouble(),
      decoration: BoxDecoration(
        color: AppColors.graphBgBar.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          height: width * 0.33,
          width: width * 0.33,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              // Edge shadow
              BoxShadow(
                offset: const Offset(1, 1.5),
                color: Theme.of(context).colorScheme.shadow,
                spreadRadius: -1.0,
                // blurRadius: 0,
              ),

              // Circular shadow
              BoxShadow(
                offset: const Offset(0.5, 0.5),
                color: Theme.of(context).colorScheme.background,
                spreadRadius: 2.0,
                blurRadius: 4,
              )
            ],
          ),
          child: innerContent,
        ),
      ),
    );
  }
}

class ProgressRings extends CustomPainter {
  final double percentValue;
  final double startAfterPercent;
  final Color colors;

  ProgressRings({
    required this.percentValue,
    required this.colors,
    this.startAfterPercent = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Offset center = Offset(size.width / 2, size.height / 2);
    double radius = min(size.width / 2, size.height / 2);

    double startArcAngle = (2 * pi * startAfterPercent) / 100;
    double arcAngle = (2 * pi * (percentValue - 3)) / 100;

    Rect boundingSquare = Rect.fromCircle(center: center, radius: radius);

    paint(List<Color> colors,
        {double startAngle = 0.0, double endAngle = pi * 2}) {
      final Gradient gradient = SweepGradient(
        startAngle: startAngle,
        endAngle: endAngle,
        colors: colors,
      );

      return Paint()
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10.0
        ..shader = gradient.createShader(boundingSquare);
    }

    canvas.drawArc(
      boundingSquare,
      startArcAngle,
      arcAngle,
      false,
      paint(
        [colors, colors.withOpacity(0.9), colors.withOpacity(0.8)],
        startAngle: (0.0).toDouble(),
        endAngle: (pi / 2).toDouble(),
      ),
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
