import 'package:flutter/material.dart';

class GridPainter extends CustomPainter {
  const GridPainter({
    required this.context,
    required this.minY,
    required this.maxY,
    required this.vertInterval,
  });

  final BuildContext context;
  final double minY, maxY;
  final double vertInterval;

  @override
  void paint(Canvas canvas, Size size) {
    final horzPaint = Paint()
      ..color = ColorScheme.of(context).outlineVariant
      ..strokeWidth = 1;

    // draw rows
    final numRows = (maxY - minY) / vertInterval;
    for (int i = 1; i < numRows; i++) {
      canvas.drawLine(
        Offset(0, i * size.height / numRows),
        Offset(size.width - 1, i * size.height / numRows),
        horzPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
