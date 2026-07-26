import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guitar_buddy/features/pitch_monitor/providers/pitch_samples_prov.dart';
import 'package:guitar_buddy/features/pitch_monitor/utils/audio_utils.dart';
import 'package:guitar_buddy/features/pitch_monitor/utils/pitch_utils.dart';
import 'package:guitar_buddy/features/pitch_monitor/widgets/pitch_chart.dart';
import 'package:guitar_buddy/features/pitch_monitor/widgets/pitch_info.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:pitch_detector_dart/pitch_detector.dart';
import 'package:pitch_detector_dart/pitch_detector_result.dart';
import 'package:record/record.dart';

class PitchMonitorPage extends ConsumerStatefulWidget {
  const PitchMonitorPage({super.key});

  @override
  ConsumerState<PitchMonitorPage> createState() => _PitchDetectorPageState();
}

class _PitchDetectorPageState extends ConsumerState<PitchMonitorPage> {
  final recorder = AudioRecorder();
  final int bufferSize = PitchDetector.DEFAULT_BUFFER_SIZE;
  // technically, hopsize is the same as buffersize to use up
  // all the extra bytes collected
  late final int hopSize = bufferSize ~/ 2;

  bool recording = false;
  String recordPath = "";
  int dataSize = 0;
  static const numChannels = 1;
  IOSink? audioSink;

  late final PitchDetector pitchDetector;

  final retention = 0.0;
  List<int> audioBuffer = [];

  @override
  void initState() {
    super.initState();

    // pitchDetector = PitchDetector.YIN(tolerance: 0.15);
    pitchDetector = PitchDetector.DYWAPITCHTRACK(tolerance: 0.20);

    recorder
        .startStream(
          RecordConfig(
            numChannels: numChannels,
            encoder: AudioEncoder.pcm16bits,
            sampleRate: PitchDetector.DEFAULT_SAMPLE_RATE,
            streamBufferSize: bufferSize * 2,
            noiseSuppress: true,
          ),
        )
        .then((stream) {
          stream.listen((data) async {
            // add to wav record file
            if (recording && audioSink != null) {
              audioSink!.add(data);
            }
            // implementing rolling buffer
            final collection = <PitchDetectorResult>[];
            for (
              audioBuffer.addAll(data);
              audioBuffer.length >= 2 * bufferSize;
              audioBuffer = audioBuffer.sublist(hopSize)
            ) {
              final rawPitch = await pitchDetector.getPitchFromIntBuffer(
                Uint8List.fromList(audioBuffer.sublist(0, 2 * bufferSize)),
              );
              if (rawPitch.pitched) {
                // ref.read(pitchSamplesProv.notifier).addPitch(rawPitch);
                // print("Pitched");
                collection.add(rawPitch);
              } else {
                // ref.read(pitchSamplesProv.notifier).addPitch(null);
                // print("Not pitched");
              }
            }

            // choose median
            final medianPitch = PitchUtils.computeMedian(
              collection,
              (t) => t.pitch,
            );
            ref.read(pitchSamplesProv.notifier).addPitch(medianPitch);

            if (medianPitch != null) {
              medianPitch.pitch =
                  (ref.read(pitchSamplesProv).lastPitchResult?.pitch ?? 0) *
                      retention +
                  medianPitch.pitch * (1 - retention);
            }

            // if (data.length < bufferSize * 2) return;
            // final rawPitch = await pitchDetector.getPitchFromIntBuffer(
            //   data.sublist(0, bufferSize * 2),
            // );
            // if (rawPitch.pitch > 0) {
            //   ref.read(pitchSamplesProv.notifier).addPitch(rawPitch);
            // } else {
            //   ref.read(pitchSamplesProv.notifier).addPitch(null);
            // }
            // print("Done");
          });
        })
        .onError((err, trace) {
          print("Failed to record");
        });
  }

  @override
  void dispose() {
    recorder.dispose();
    pitchDetector.dispose();
    super.dispose();
  }

  void startRecord(String recordPath) {
    audioSink = File(recordPath).openWrite();
    // add empty header
    audioSink!.add(
      AudioUtils.pcm16wavHeader(
        0,
        numChannels,
        PitchDetector.DEFAULT_SAMPLE_RATE,
      ),
    );
  }

  Future<void> stopRecord(String recordPath) async {
    await audioSink!.flush();
    await audioSink!.close();
    audioSink = null;
    // replace with updated header
    final raf = await File(recordPath).open(mode: FileMode.append);
    await raf.setPosition(0);
    await raf.writeFrom(
      AudioUtils.pcm16wavHeader(
        dataSize,
        numChannels,
        PitchDetector.DEFAULT_SAMPLE_RATE,
      ),
    );
    await raf.flush();
    await raf.close();
  }

  @override
  Widget build(BuildContext context) {
    final recordBtn = Material(
      key: ValueKey(recording),
      elevation: 1,
      borderRadius: BorderRadius.circular(1000),
      child: IconButton.filledTonal(
        style: recording
            ? ButtonStyle(
                foregroundColor: WidgetStatePropertyAll(
                  ColorScheme.of(context).onErrorContainer,
                ),
                backgroundColor: WidgetStatePropertyAll(
                  ColorScheme.of(context).errorContainer,
                ),
              )
            : null,
        onPressed: () async {
          // start record
          if (recording && audioSink != null) {
            setState(() {
              recording = false;
            });
            await stopRecord(recordPath);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Recorded at $recordPath"),
                  elevation: 2,
                  action: SnackBarAction(
                    label: "Open",
                    onPressed: () async {
                      await OpenFile.open(recordPath, linuxUseGio: false);
                    },
                  ),
                ),
              );
            }
          } else if (!recording) {
            final saveDir = await getApplicationSupportDirectory();
            recordPath = path.join(saveDir.path, AudioUtils.getAudioFileName());
            dataSize = 0;
            setState(() {
              startRecord(recordPath); // add empty header
              recording = true;
            });
          }
        },
        tooltip: recording ? "Save" : "Record",
        icon: Icon(
          recording
              ? Symbols.stop_rounded
              : Symbols.radio_button_checked_rounded,
          size: kDefaultFontSize * 1.5,
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text("Pitch Monitor"),
        actions: [
          AnimatedSwitcher(
            duration: Duration(milliseconds: 350),
            reverseDuration: Duration(milliseconds: 350),
            switchInCurve: Curves.linearToEaseOut,
            switchOutCurve: Curves.linearToEaseOut,
            child: recordBtn,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 10,
          children: [
            Expanded(
              child: Material(
                elevation: 2,
                borderRadius: BorderRadius.circular(10),
                color: ColorScheme.of(context).surfaceContainerLow,
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: PitchChart(),
                ),
              ),
            ),

            PitchInfo(),
          ],
        ),
      ),
    );
  }
}
