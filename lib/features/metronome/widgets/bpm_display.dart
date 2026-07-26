import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class BpmDisplay extends StatelessWidget {
  const BpmDisplay({
    super.key,
    required this.bpm,
    required this.bpmIncrementFunc,
    required this.bpmDecrementFunc,
  });

  final int bpm;
  final void Function() bpmIncrementFunc, bpmDecrementFunc;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 20,
          children: [
            Material(
              borderRadius: BorderRadius.circular(1000),
              elevation: 2,
              child: IconButton.filledTonal(
                onPressed: bpmDecrementFunc,
                icon: Icon(Symbols.remove_rounded),
              ),
            ),
            Text(
              "$bpm",
              style: TextStyle(
                fontSize: 60,
                fontWeight: FontWeight.bold,
                color: ColorScheme.of(context).primary,
              ),
            ),
            Material(
              borderRadius: BorderRadius.circular(1000),
              elevation: 2,
              child: IconButton.filledTonal(
                onPressed: bpmIncrementFunc,
                icon: Icon(Symbols.add_rounded),
              ),
            ),
          ],
        ),

        Text(
          "BPM",
          style: TextStyle(
            color: ColorScheme.of(context).onSurface.withAlpha(200),
            fontSize: 20,
          ),
        ),
      ],
    );
  }
}
