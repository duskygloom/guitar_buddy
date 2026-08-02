import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guitar_buddy/features/pitch_monitor/providers/pitch_samples_prov.dart';
import 'package:guitar_buddy/features/pitch_monitor/utils/pitch_utils.dart';
import 'package:guitar_buddy/main_theme.dart';

class PitchChart extends ConsumerStatefulWidget {
  const PitchChart({super.key});

  static const minChartScale = 2.0;
  static const maxChartScale = 5.0;

  static const minNote = 26.0;
  static const maxNote = 86.0;

  @override
  ConsumerState<PitchChart> createState() => _PitchChartState();
}

class _PitchChartState extends ConsumerState<PitchChart> {
  final transformCtrl = TransformationController(
    Matrix4.identity()..scaleByDouble(1, PitchChart.minChartScale, 1, 1),
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
    final samples = ref.watch(pitchSamplesProv).samples;

    final maxSeconds =
        (DateTime.now().millisecondsSinceEpoch).roundToDouble() / 1000;
    final scrollDuration =
        MediaQuery.sizeOf(context).width /
        500 *
        ref.watch(pitchSamplesProv.notifier).recordSecs;

    return LineChart(
      transformationConfig: transformConfig,
      duration: Duration.zero,
      LineChartData(
        lineBarsData: List.generate(samples.length, (si) {
          final sample = samples[si];
          return LineChartBarData(
            isCurved: true,
            curveSmoothness: 0.2,
            color: ColorScheme.of(context).primary,
            barWidth: 2,
            dotData: FlDotData(
              show: false,
              getDotPainter: (p0, p1, p2, p3) =>
                  FlDotCirclePainter(radius: 2, color: Colors.yellow),
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
        minY: PitchChart.minNote - 0.5,
        maxY: PitchChart.maxNote + 0.5,
        maxX: maxSeconds,
        minX: maxSeconds - scrollDuration,
        clipData: FlClipData.all(),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(horizontalInterval: 1, verticalInterval: 5),
        lineTouchData: LineTouchData(
          enabled: false,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (touchedSpot) =>
                ColorScheme.of(context).surfaceContainerHigh.withAlpha(200),
            getTooltipItems: (spots) => List.generate(spots.length, (index) {
              return LineTooltipItem(
                PitchUtils.noteToString(spots[index].y),
                TextStyle(),
              );
            }),
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
                final colors = [
                  MainTheme.redOf(context),
                  MainTheme.blueOf(context),
                ];
                final octave = value.round() ~/ 12 - 2;
                final isSharp = PitchUtils.noteIsSharp(value);
                return Text(
                  isSharp ? "" : PitchUtils.noteToString(value),
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
