import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guitar_buddy/features/pitch_monitor/providers/pitch_samples_prov.dart';
import 'package:guitar_buddy/features/pitch_monitor/widgets/metric_card.dart';
import 'package:guitar_buddy/features/tuner/models/pitch_calculator.dart';
import 'package:pitchupdart/instrument_type.dart';
import 'package:pitchupdart/pitch_handler.dart';

class PitchInfo extends ConsumerWidget {
  const PitchInfo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pitchResult = ref.watch(pitchSamplesProv).lastPitchResult;
    final cardValueTextStyle = TextStyle(
      color: ColorScheme.of(context).primary,
      fontSize: kDefaultFontSize * 2,
      fontWeight: FontWeight.bold,
    );

    final children = [
      MetricCard(
        title: "Note",
        child: Text(
          pitchResult == null
              ? "-"
              : PitchCalculator.pitchToNote(pitchResult.pitch) ?? "-",
          style: cardValueTextStyle,
        ),
      ),

      MetricCard(
        title: "Probability",
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              pitchResult == null
                  ? "-"
                  : (pitchResult.probability * 100).round().toString(),
              style: cardValueTextStyle,
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: pitchResult?.probability ?? 0.0,
                color: ColorScheme.of(context).primary,
                minHeight: 8,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ],
        ),
      ),

      Builder(
        builder: (context) {
          final double diffCents;
          if (pitchResult == null) {
            diffCents = double.nan;
          } else {
            final handler = PitchHandler(InstrumentType.guitar);
            diffCents = handler.handlePitch(pitchResult.pitch).diffCents;
          }
          return MetricCard(
            title: "Offset",
            child: Text(
              pitchResult == null
                  ? "-"
                  : "${diffCents > 0 ? '+' : ''}${diffCents.round() / 100}",
              style: cardValueTextStyle,
            ),
          );
        },
      ),

      MetricCard(
        title: "Frequency",
        child: Text(
          pitchResult == null ? "-" : "${pitchResult.pitch.round()} Hz",
          style: cardValueTextStyle,
        ),
      ),
    ];

    return Container(
      alignment: Alignment.center,
      height: kDefaultFontSize * 8,
      child: ListView.separated(
        itemCount: children.length,
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return SizedBox(width: kDefaultFontSize * 12, child: children[index]);
        },
        separatorBuilder: (context, index) => SizedBox(width: 10),
      ),
    );
  }
}
