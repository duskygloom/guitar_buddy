import 'package:flutter/material.dart';
import 'package:guitar_buddy/features/pitch_monitor/models/pitch_store.dart';
import 'package:guitar_buddy/features/pitch_monitor/utils/pitch_utils.dart';

class ChartPainter extends CustomPainter {
  const ChartPainter({
    required this.context,
    required this.minX,
    required this.maxX,
    required this.minY,
    required this.maxY,
    required this.samples,
    required this.vertInterval,
    required this.horzInterval,
  });

  final BuildContext context;
  final double minX, maxX, minY, maxY;
  final double vertInterval, horzInterval;
  final List<PitchSample> samples;

  @override
  void paint(Canvas canvas, Size size) {
    Offset toWorld(double x, double y) {
      final xx = size.width / (maxX - minX) * (x - minX);
      final yy = size.height / (maxY - minY) * (y - minY);
      return Offset(xx.clamp(0, size.width), yy.clamp(0, size.height));
    }

    for (final sample in samples) {
      for (var i = 1; i < sample.length; i++) {
        final worldPtFrom = toWorld(
          sample[i - 1].time.millisecondsSinceEpoch / 1000,
          PitchUtils.pitchToNote(sample[i - 1].frequency),
        );
        final worldPtTo = toWorld(
          sample[i].time.millisecondsSinceEpoch / 1000,
          PitchUtils.pitchToNote(sample[i].frequency),
        );
        // final worldPt = Offset(size.width / 2, size.height / 2);
        if (worldPtTo.dx == 0 && worldPtFrom.dx == 0) continue;
        canvas.drawLine(
          worldPtFrom,
          worldPtTo,
          Paint()..color = ColorScheme.of(context).primary,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant ChartPainter oldDelegate) {
    return samples != oldDelegate.samples ||
        minY != oldDelegate.minY ||
        maxY != oldDelegate.maxY ||
        vertInterval != oldDelegate.vertInterval;
  }
}
