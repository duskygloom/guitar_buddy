import 'package:flutter/material.dart';

class BpmCtrl extends StatelessWidget {
  const BpmCtrl({
    super.key,
    required this.bpm,
    required this.minBpm,
    required this.maxBpm,
    required this.onBpmChanged,
  });

  final int bpm, minBpm, maxBpm;
  final void Function(double value) onBpmChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Slider(
          value: bpm.toDouble(),
          min: minBpm.toDouble(),
          max: maxBpm.toDouble(),
          onChanged: onBpmChanged,
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "${minBpm.round()}",
              style: TextStyle(
                color: ColorScheme.of(context).onSurface.withAlpha(150),
              ),
            ),
            Text(
              "${maxBpm.round()}",
              style: TextStyle(
                color: ColorScheme.of(context).onSurface.withAlpha(150),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
