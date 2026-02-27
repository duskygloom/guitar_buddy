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
          RecordConfig(
            encoder: AudioEncoder.pcm16bits,
            numChannels: 1,
            noiseSuppress: true,
          ),
        )
        .then((stream) {
          audioSubscription = stream.listen((data) async {
            final rawPitch = await pitchDetector.getPitchFromIntBuffer(data);
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
    final value = pitchResult?.diffCents ?? double.nan;
    final noteToken = Token(
      pitchResult?.note ?? "--",
      isChord: pitchResult != null,
    );
    final expectedPitch = pitchResult?.expectedFrequency ?? double.nan;
    final actualPitch = pitchResult == null
        ? double.nan
        : (pitchResult!.expectedFrequency - pitchResult!.diffFrequency);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          processedNote ?? "--",
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: ColorScheme.of(context).primary,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          expectedPitch.isNaN
              ? "(--)"
              : "(${expectedPitch.toStringAsFixed(1)} Hz)",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: ColorScheme.of(context).secondary,
          ),
          textAlign: TextAlign.center,
        ),
        Row(
          spacing: 30,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _NoteText((noteToken - 1).text, textAlign: TextAlign.right),
            ArcGraph(value: value),
            _NoteText((noteToken + 1).text, textAlign: TextAlign.left),
          ],
        ),
        Text(
          expectedPitch.isNaN ? "--" : "${actualPitch.toStringAsFixed(1)} Hz",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: ColorScheme.of(context).secondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _NoteText extends StatelessWidget {
  const _NoteText(this.note, {this.textAlign});

  final String note;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      width: 80,
      child: Text(
        note,
        style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
        textAlign: textAlign ?? TextAlign.center,
      ),
    );
  }
}
