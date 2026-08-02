import 'dart:async';

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:guitar_buddy/features/pitch_monitor/utils/pitch_utils.dart';
import 'package:guitar_buddy/features/pitch_monitor/widgets/pitch_chart.dart';
import 'package:guitar_buddy/features/tuner/widgets/snackbars.dart';
import 'package:guitar_buddy/main_theme.dart';
import 'package:pitch_detector_dart/pitch_detector.dart';
import 'package:pitch_detector_dart/pitch_detector_result.dart';
import 'package:pitchupdart/instrument_type.dart';
import 'package:pitchupdart/pitch_handler.dart';
import 'package:pitchupdart/pitch_result.dart';

import 'package:guitar_buddy/features/tuner/models/chord_parser.dart';
import 'package:guitar_buddy/features/tuner/models/pitch_calculator.dart';
import 'package:guitar_buddy/features/tuner/widgets/arc_graph.dart';
import 'package:pitchupdart/tuning_status.dart';
import 'package:record/record.dart';

class TunerMeter extends StatefulWidget {
  const TunerMeter({super.key});

  @override
  State<TunerMeter> createState() => _TunerMeterState();
}

class _TunerMeterState extends State<TunerMeter> {
  final bufferSize = PitchDetector.DEFAULT_BUFFER_SIZE;
  late final hopSize = bufferSize ~/ 2;

  final _audioRecorder = AudioRecorder();
  late final _pitchDetector = PitchDetector.YINFFI(
    bufferSize: bufferSize,
    tolerance: 0.1,
    minFreq: PitchUtils.noteToPitch(PitchChart.minNote),
    maxFreq: PitchUtils.noteToPitch(PitchChart.maxNote),
  );
  final _pitchHandler = PitchHandler(InstrumentType.guitar);
  late StreamSubscription<Uint8List> _audioSubscription;
  PitchResult? _pitchResult;
  String? _processedNote;

  List<int> _audioBuffer = [];

  @override
  void initState() {
    super.initState();

    _audioRecorder
        .startStream(
          RecordConfig(
            encoder: AudioEncoder.pcm16bits,
            numChannels: 1,
            noiseSuppress: true,
            streamBufferSize: 2 * bufferSize,
          ),
        )
        .then((stream) {
          _audioSubscription = stream.listen(
            (data) async {
              // implementing rolling buffer
              final collection = <PitchDetectorResult>[];
              for (
                _audioBuffer.addAll(data);
                _audioBuffer.length >= 2 * bufferSize;
                _audioBuffer = _audioBuffer.sublist(hopSize)
              ) {
                final rawPitch = await _pitchDetector.getPitchFromIntBuffer(
                  Uint8List.fromList(_audioBuffer.sublist(0, 2 * bufferSize)),
                );
                if (rawPitch.pitched) {
                  collection.add(rawPitch);
                }
              }

              // choose median
              final medianPitch = PitchUtils.computeMedian(
                collection,
                (t) => t.pitch,
              );

              if (medianPitch != null && medianPitch.pitched) {
                final handledPitch = _pitchHandler.handlePitch(
                  medianPitch.pitch,
                );
                if (handledPitch.note.isNotEmpty) {
                  setState(() {
                    _pitchResult = handledPitch;
                    _processedNote = PitchCalculator.pitchToNote(
                      medianPitch.pitch,
                    );
                  });
                }
              }
            },
            onError: (err, trace) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  Snackbars.error(context, "Failed to record audio."),
                );
              }
            },
          );
        });
  }

  @override
  void dispose() {
    _audioSubscription.cancel().then((_) {});
    _audioRecorder.dispose();
    _pitchDetector.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double diffValue;
    if (_pitchResult != null) {
      diffValue = -_pitchResult!.diffCents;
    } else {
      diffValue = double.nan;
    }

    final Color valueColor;
    switch (_pitchResult?.tuningStatus) {
      case TuningStatus.waytoolow:
      case TuningStatus.toolow:
        valueColor = MainTheme.blueOf(context);
        break;
      case TuningStatus.waytoohigh:
      case TuningStatus.toohigh:
        valueColor = MainTheme.redOf(context);
        break;
      case TuningStatus.tuned:
        valueColor = MainTheme.greenOf(context);
        break;
      case TuningStatus.undefined:
      case null:
        valueColor = ColorScheme.of(context).onSurface.withAlpha(50);
        break;
    }

    final noteToken = NoteToken(
      _pitchResult?.note ?? "-",
      isChord: _pitchResult != null,
    );
    final expectedPitch = _pitchResult?.expectedFrequency ?? double.nan;

    final figureWidth = MediaQuery.sizeOf(context).width.clamp(100, 800);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _processedNote ?? "-",
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 30),
        SizedBox(
          width: figureWidth - 80,
          height: (figureWidth - 80) / 2,
          child: ArcGraph(value: diffValue, valueColor: valueColor),
        ),
        Card(
          child: SizedBox(
            width: 120,
            child: Text(
              expectedPitch.isNaN
                  ? "-"
                  : (diffValue >= 0 ? "+" : "") + diffValue.toStringAsFixed(1),
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Container(
          width: figureWidth.toDouble(),
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                (noteToken - 1).text,
                style: TextStyle(
                  color: MainTheme.blueOf(context),
                  fontWeight: FontWeight.bold,
                  fontSize: 36,
                ),
              ),
              Text(
                (noteToken + 1).text,
                style: TextStyle(
                  color: MainTheme.redOf(context),
                  fontWeight: FontWeight.bold,
                  fontSize: 36,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
