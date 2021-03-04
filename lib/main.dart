import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mandelbrot_set/complex.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Mandelbrot(),
    );
  }
}

class Mandelbrot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: MandelbrotPainter(
        pixelRatio: MediaQuery.of(context).devicePixelRatio,
      ),
    );
  }
}

class Axis extends StatefulWidget {
  @override
  _AxisState createState() => _AxisState();
}

class _AxisState extends State<Axis> with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  double currentScale = 4;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      lowerBound: 0.0,
      upperBound: 1000.0,
      value: currentScale,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: GestureDetector(
        onTap: animateUp,
        onDoubleTap: animateDown,
        onHorizontalDragUpdate: (details) {
          currentScale += details.delta.distance * details.delta.dx.sign;
          controller.value = currentScale;
        },
        child: AnimatedBuilder(
            animation: controller,
            builder: (context, child) {
              return CustomPaint(painter: AxisPainter(scale: controller.value));
            }),
      ),
    );
  }

  void animateDown() => controller.animateTo(
        currentScale /= 2,
        curve: Curves.easeInOut,
        duration: Duration(milliseconds: 400),
      );

  void animateUp() => controller.animateTo(
        currentScale *= 2,
        curve: Curves.easeInOut,
        duration: Duration(milliseconds: 400),
      );
}

class AxisPainter extends CustomPainter {
  /// Display 1 axis step (0 -> 1) in horizontal direction
  final double scale;

  final _paint = Paint()..color = Colors.black;

  AxisPainter({
    required this.scale,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final halfWidth = width / 2;

    final height = size.height;
    final halfHeight = height / 2;

    canvas.save();
    canvas.scale(1, -1);
    canvas.translate(halfWidth, -halfHeight);

    final pixelsPerStep = halfWidth / scale;

    for (double x = pixelsPerStep; x < halfWidth; x += pixelsPerStep) {
      canvas.drawLine(Offset(-x, 10), Offset(-x, -10), _paint);
      canvas.drawLine(Offset(x, 10), Offset(x, -10), _paint);
    }

    for (double y = pixelsPerStep; y < halfHeight; y += pixelsPerStep) {
      canvas.drawLine(Offset(-10, y), Offset(10, y), _paint);
      canvas.drawLine(Offset(-10, -y), Offset(10, -y), _paint);
    }

    canvas.drawLine(Offset(-halfWidth, 0), Offset(halfWidth, 0), _paint);
    canvas.drawLine(Offset(0, -halfHeight), Offset(0, halfHeight), _paint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant AxisPainter oldDelegate) => true;
}

int divergeCount(Complex complex, {int precision = 100}) {
  Complex running = complex;
  for (int step = 0; step < precision; step++) {
    if (running.modulusSqr() > 4) return step;

    running = running.sqr() + complex;
  }

  return precision;
}

class MandelbrotPoint {
  final Offset offset;
  final bool isDiverging;

  const MandelbrotPoint({
    required this.offset,
    required this.isDiverging,
  });
}

class MandelbrotPainter extends CustomPainter {
  final double pixelRatio;

  final Paint p = Paint()..strokeWidth = 1;

  MandelbrotPainter({required this.pixelRatio});

  @override
  void paint(Canvas canvas, Size size) {
    print(pixelRatio);

    canvas.drawColor(Colors.black, BlendMode.src);

    final width = size.width;
    final halfWidth = width / 2;

    final height = size.height;
    final halfHeight = height / 2;

    canvas.save();
    canvas.scale(1, -1);
    canvas.translate(halfWidth, -halfHeight);

    for (double x = -halfWidth; x < halfWidth; x++) {
      final real = map(x, -halfWidth, halfWidth, -2, 0.6);

      for (double y = -halfHeight; y < halfHeight; y++) {
        final imaginary = map(y, -halfHeight, halfHeight, -1.3, 1.3);

        final precision = 200;
        final divergesAt = divergeCount(
          Complex(real: real, imaginary: imaginary),
          precision: precision,
        );

        late final Color color;
        if (divergesAt == precision) {
          continue;

          color = Colors.black;
        } else {
          final norm = divergesAt / precision;
          final p = pow(norm, 0.4).toDouble();
          final hue = map(p, 0, 1, 0, 360).clamp(0, 360).floorToDouble();

          color = HSLColor.fromAHSL(1, hue, 1, 0.5).toColor();
        }

        canvas.drawPoints(PointMode.points, [Offset(x, y)], p..color = color);
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

double map(
  double value,
  double lowOrig,
  double highOrig,
  double lowNew,
  double highNew,
) =>
    lowNew + (value - lowOrig) / (highOrig - lowOrig) * (highNew - lowNew);
