import 'dart:async';

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:guitar_buddy/models/chord_parser.dart';
import 'package:guitar_buddy/models/pitch_calculator.dart';
import 'package:guitar_buddy/widgets/arc_graph.dart';
import 'package:pitch_detector_dart/pitch_detector.dart';
import 'package:pitchupdart/instrument_type.dart';
import 'package:pitchupdart/pitch_handler.dart';
import 'package:pitchupdart/pitch_result.dart';
import 'package:record/record.dart';

class TunerMeter extends StatefulWidget {
  const TunerMeter({super.key});

  @override
  State<TunerMeter> createState() => _TunerMeterState();
}

class _TunerMeterState extends State<TunerMeter> {
  final audioRecorder = AudioRecorder();
  final pitchDetector = PitchDetector();
  final pitchHandler = PitchHandler(InstrumentType.guitar);
  late StreamSubscription<Uint8List> audioSubscription;
  PitchResult? pitchResult;
  String? processedNote;

  @override
  void initState() {
    super.initState();
    audioRecorder
        .startStream(
          RecordConfig(encoder: AudioEncoder.pcm16bits, numChannels: 1),
        )
        .then((stream) {
          audioSubscription = stream.listen((data) async {
            if (data.length < 4096) return;
            final rawPitch = await pitchDetector.getPitchFromIntBuffer(
              data.sublist(0, 4096),
            );
            if (rawPitch.pitched) {
              final handledPitch = await pitchHandler.handlePitch(
                rawPitch.pitch,
              );
              if (handledPitch.note.isNotEmpty) {
                setState(() {
                  pitchResult = handledPitch;
                  processedNote = PitchCalculator.pitchToNote(rawPitch.pitch);
                });
              }
            }
          });
        });
  }

  @override
  void dispose() {
    audioSubscription.cancel().then((_) {});
    audioRecorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final value = -(pitchResult?.diffCents ?? double.nan);
    // final value = 100.0;
    final Color valueColor;
    if (value < -10) {
      valueColor = Colors.blueAccent;
    } else if (value > 10) {
      valueColor = Colors.redAccent;
    } else {
      valueColor = Colors.greenAccent;
    }

    final noteToken = Token(
      pitchResult?.note ?? "--",
      isChord: pitchResult != null,
    );
    final expectedPitch = pitchResult?.expectedFrequency ?? double.nan;

    final figureWidth = MediaQuery.sizeOf(context).width.clamp(100, 800);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          processedNote ?? "--",
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
          child: ArcGraph(value: value, valueColor: valueColor),
        ),
        Card(
          child: SizedBox(
            width: 120,
            child: Text(
              expectedPitch.isNaN
                  ? "--"
                  : (value >= 0 ? "+" : "") + value.toStringAsFixed(1),
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
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 36,
                ),
              ),
              Text(
                (noteToken + 1).text,
                style: TextStyle(
                  color: Colors.redAccent,
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
