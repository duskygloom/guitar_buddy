import 'package:flutter/material.dart';
import 'package:guitar_buddy/features/pitch_monitor/utils/pitch_utils.dart';

class LabelPainter extends CustomPainter {
  const LabelPainter({
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
    // draw rows
    final numRows = (maxY - minY) / vertInterval;
    for (int i = 1; i < numRows; i++) {
      final octave = (maxY - i).round() ~/ 12 - 2;
      final colors = [Colors.redAccent, Colors.lightBlueAccent];
      final tp = TextPainter(
        text: TextSpan(
          text: PitchUtils.noteToString(maxY - i),
          style: TextTheme.of(
            context,
          ).bodyMedium?.copyWith(color: colors[octave % colors.length]),
        ),
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      tp.paint(
        canvas,
        Offset(0, i * size.height / numRows - kDefaultFontSize / 1.5),
      );
    }
  }

  @override
  bool shouldRepaint(covariant LabelPainter oldDelegate) {
    return oldDelegate.minY != minY || oldDelegate.maxY != maxY;
  }
}

/*
class _PitchChartState extends ConsumerState<PitchChart> {
  final transformCtrl = TransformationController(
    Matrix4(1, 0, 0, 0, 0, 5, 0, 0, 0, 0, 1, 0, 0, -1480, 0, 1),
  );

  late final transformConfig = FlTransformationConfig(
    scaleAxis: FlScaleAxis.vertical,
    trackpadScrollCausesScale: false,
    minScale: PitchChart.minChartScale,
    maxScale: PitchChart.maxChartScale,
    transformationController: transformCtrl,
  );

  @override
  void dispose() {
    transformCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pitchStore = ref.watch(pitchSamplesProvider);
    final samples = pitchStore.samples;

    final maxSeconds = DateTime.now().millisecondsSinceEpoch / 1000;
    final scrollDuration = ref
        .watch(pitchSamplesProvider.notifier)
        .recordDuration;

    final viewConfig = ref.watch(viewConfigProvider);
    final startNote = viewConfig.startNote;
    final notesInView = viewConfig.notesInView;

    return LineChart(
      transformationConfig: transformConfig,
      duration: Duration.zero,
      LineChartData(
        lineBarsData: List.generate(samples.length, (si) {
          final sample = samples[si];
          return LineChartBarData(
            isCurved: true,
            curveSmoothness: 0.25,
            dotData: FlDotData(
              show: false,
              getDotPainter: (_, _, _, _) =>
                  FlDotCirclePainter(radius: 2, color: Colors.yellowAccent),
            ),
            spots: List.generate(sample.length, (index) {
              final noteData = PitchUtils.pitchToNote(sample[index].frequency);
              return FlSpot(
                sample[index].time.millisecondsSinceEpoch / 1000,
                noteData.isNaN ? 0 : noteData,
              );
            }),
          );
        }),
        minY: startNote - 1,
        maxY: startNote + notesInView,
        maxX: maxSeconds,
        minX: maxSeconds - scrollDuration.inSeconds,
        clipData: FlClipData.all(),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(horizontalInterval: 1, verticalInterval: 5),
        lineTouchData: LineTouchData(
          enabled: false,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (touchedSpot) =>
                ColorScheme.of(context).surfaceContainerHigh.withAlpha(200),
            getTooltipItems: (spots) => List.generate(
              spots.length,
              (index) => LineTooltipItem(
                PitchUtils.noteToString(spots[index].y),
                TextStyle(),
              ),
            ),
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              reservedSize: kDefaultFontSize * 2.2,
              minIncluded: false,
              maxIncluded: false,
              getTitlesWidget: (value, meta) {
                final colors = [Colors.redAccent, Colors.blueAccent];
                final octave = value.round() ~/ 12 - 2;
                return Text(
                  PitchUtils.noteToString(value),
                  textAlign: TextAlign.left,
                  style: TextStyle(color: colors[(octave) % colors.length]),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(),
          topTitles: AxisTitles(),
        ),
      ),
    );
  }
}
*/
