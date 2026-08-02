import 'dart:math' as math;

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
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;

    final Paint valuePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 34
      ..strokeCap = StrokeCap.butt
      ..color = value.isNaN
          ? ColorScheme.of(context).surfaceContainer
          : valueColor;

    final surfacePaint = Paint()
      ..color = ColorScheme.of(context).surface
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.butt;

    canvas.drawArc(rect, 0, -math.pi, false, backgroundPaint);

    final sweep = value.isNaN ? 0.0 : (value / 100) * math.pi / 2;
    final width = 0.03;
    canvas.drawArc(
      rect,
      -math.pi / 2 + sweep - width * 2,
      width * 4,
      false,
      surfacePaint,
    );
    canvas.drawArc(
      rect,
      -math.pi / 2 + sweep - width / 2,
      width,
      false,
      valuePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ArcGraphPainter oldDelegate) {
    return oldDelegate.value != value;
  }
}
