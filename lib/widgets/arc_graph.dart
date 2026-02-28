import 'dart:math';

import 'package:flutter/material.dart';

class ArcGraph extends StatelessWidget {
  const ArcGraph({super.key, required this.value, required this.valueColor});

  final double value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _ArcGraphPainter(context, value, valueColor));
  }
}

class _ArcGraphPainter extends CustomPainter {
  const _ArcGraphPainter(this.context, this.value, this.valueColor);

  final BuildContext context;
  final double value;
  final Color valueColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2;

    final rect = Rect.fromCircle(center: center, radius: radius);

    final backgroundPaint = Paint()
      ..color = ColorScheme.of(context).surfaceContainer
      ..style = PaintingStyle.stroke
      ..strokeWidth = 23
      ..strokeCap = StrokeCap.round;

    final Paint valuePaint;
    if (value.isNaN) {
      valuePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 15
        ..strokeCap = StrokeCap.round;
    } else {
      final Color valueColor;
      if (value < -10) {
        valueColor = Colors.blueAccent;
      } else if (value > 10) {
        valueColor = Colors.redAccent;
      } else {
        valueColor = Colors.greenAccent;
      }
      valuePaint = Paint()
        ..color = valueColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 15
        ..strokeCap = StrokeCap.round;
    }

    canvas.drawArc(rect, pi, pi, false, backgroundPaint);

    final sweep = value.isNaN ? 0.0 : (value / 100) * pi / 2;
    canvas.drawArc(rect, -pi / 2, sweep, false, valuePaint);
  }

  @override
  bool shouldRepaint(covariant _ArcGraphPainter oldDelegate) {
    return oldDelegate.value != value;
  }
}
