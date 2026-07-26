import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guitar_buddy/features/pitch_monitor/providers/pitch_samples_prov.dart';
import 'package:guitar_buddy/features/pitch_monitor/providers/view_config_prov.dart';
import 'package:guitar_buddy/features/pitch_monitor/utils/pitch_utils.dart';
// import 'package:guitar_buddy/features/pitch_detector/widgets/chart_painter.dart';
// import 'package:guitar_buddy/features/pitch_detector/widgets/grid_painter.dart';
// import 'package:guitar_buddy/features/pitch_detector/widgets/label_painter.dart';

class PitchChart extends ConsumerStatefulWidget {
  const PitchChart({super.key});

  static const minChartScale = 4.0;
  static const maxChartScale = 8.0;

  @override
  ConsumerState<PitchChart> createState() => _PitchChartState();
}

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
    final samples = ref.watch(pitchSamplesProv).samples;

    final maxSeconds =
        (DateTime.now().millisecondsSinceEpoch).roundToDouble() / 1000;
    final scrollDuration = ref.watch(pitchSamplesProv.notifier).recordDuration;

    final startNote = ref.watch(viewConfigProv).startNote;
    final notesInView = ref.watch(viewConfigProv).notesInView;

    // return GestureDetector(
    //   onScaleUpdate: (details) {
    //     if (details.focalPointDelta.dx == 0) {
    //       ref
    //           .read(viewConfigProv.notifier)
    //           .setStartNote(startNote - details.focalPointDelta.dy);
    //     }
    //     ref
    //         .read(viewConfigProv.notifier)
    //         .setNotesInView(notesInView ~/ details.verticalScale);
    //   },
    //   child: Stack(
    //     fit: StackFit.expand,
    //     alignment: Alignment.center,
    //     children: [
    //       Padding(
    //         padding: EdgeInsets.only(left: kDefaultFontSize * 2.5),
    //         child: CustomPaint(
    //           painter: GridPainter(
    //             context: context,
    //             minY: startNote - 1,
    //             maxY: startNote + notesInView,
    //             vertInterval: 1,
    //           ),
    //         ),
    //       ),
    //       Padding(
    //         padding: EdgeInsets.only(left: kDefaultFontSize * 2.5),
    //         child: CustomPaint(
    //           painter: ChartPainter(
    //             context: context,
    //             minX: maxSeconds.toDouble() - scrollDuration.inSeconds,
    //             maxX: maxSeconds.toDouble(),
    //             minY: startNote - 1,
    //             maxY: startNote + notesInView,
    //             horzInterval: 5,
    //             vertInterval: 1,
    //             samples: samples,
    //           ),
    //         ),
    //       ),
    //       CustomPaint(
    //         painter: LabelPainter(
    //           context: context,
    //           minY: startNote - 1,
    //           maxY: startNote + notesInView,
    //           vertInterval: 1,
    //         ),
    //       ),
    //     ],
    //   ),
    // );

    return LineChart(
      transformationConfig: transformConfig,
      duration: Duration.zero,
      LineChartData(
        lineBarsData: List.generate(samples.length, (si) {
          final sample = samples[si];
          return LineChartBarData(
            isCurved: true,
            curveSmoothness: 0.2,
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
