import 'dart:async';

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guitar_buddy/features/pitch_monitor/providers/pitch_samples_prov.dart';
import 'package:guitar_buddy/features/pitch_monitor/utils/audio_utils.dart';
import 'package:guitar_buddy/features/pitch_monitor/utils/pitch_utils.dart';
import 'package:guitar_buddy/features/pitch_monitor/widgets/pitch_chart.dart';
import 'package:guitar_buddy/features/pitch_monitor/widgets/record_btn.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:pitch_detector_dart/pitch_detector.dart';
import 'package:pitch_detector_dart/pitch_detector_result.dart';
import 'package:record/record.dart';

class PitchMonitor extends ConsumerStatefulWidget {
  const PitchMonitor({super.key});

  @override
  ConsumerState<PitchMonitor> createState() => _PitchMonitorState();
}

class _PitchMonitorState extends ConsumerState<PitchMonitor> {
  final _recorder = AudioRecorder();
  final int bufferSize = PitchDetector.DEFAULT_BUFFER_SIZE;
  // technically, hopsize is the same as buffersize to use up
  // all the extra bytes collected
  late final int hopSize = bufferSize ~/ 2;

  bool _recording = false;
  String _recordPath = "";
  DateTime _recordStart = DateTime(0);
  int _dataSize = 0;
  static const numChannels = 1;
  IOSink? _audioSink;

  late final PitchDetector _pitchDetector = PitchDetector.YINFFI(
    bufferSize: bufferSize,
    tolerance: 0.15,
    minFreq: PitchUtils.noteToPitch(PitchChart.minNote),
    maxFreq: PitchUtils.noteToPitch(PitchChart.maxNote),
  );

  final retention = 0.0;
  List<int> _audioBuffer = [];

  @override
  void initState() {
    super.initState();

    _recorder
        .startStream(
          RecordConfig(
            numChannels: numChannels,
            encoder: AudioEncoder.pcm16bits,
            sampleRate: PitchDetector.DEFAULT_SAMPLE_RATE,
            streamBufferSize: 2 * bufferSize,
            noiseSuppress: true,
          ),
        )
        .then((stream) {
          stream.listen((data) async {
            // add to wav record file
            if (_recording && _audioSink != null) {
              _audioSink!.add(data);
              setState(() {
                _recordStart = _recordStart;
              });
            }
            // implementing rolling buffer
            final collection = <PitchDetectorResult>[];
            _audioBuffer.clear();
            _audioBuffer.addAll(data);
            for (
              ;
              _audioBuffer.length >= 2 * bufferSize;
              _audioBuffer = _audioBuffer.sublist(hopSize)
            ) {
              final rawPitch = await _pitchDetector.getPitchFromIntBuffer(
                Uint8List.fromList(_audioBuffer.sublist(0, 2 * bufferSize)),
              );
              if (rawPitch.pitched) {
                collection.add(rawPitch);
                ref.read(pitchSamplesProv.notifier).addPitch(rawPitch);
              } else {
                ref.read(pitchSamplesProv.notifier).addPitch(null);
              }
            }

            // choose median
            // final medianPitch = PitchUtils.computeMedian(
            //   collection,
            //   (t) => t.pitch,
            // );

            // if (medianPitch != null) {
            //   medianPitch.pitch =
            //       (ref.read(pitchSamplesProv).lastPitchResult?.pitch ?? 0) *
            //           retention +
            //       medianPitch.pitch * (1 - retention);
            // }

            // ref.read(pitchSamplesProv.notifier).addPitch(medianPitch);
          });
        });
  }

  @override
  void dispose() {
    _recorder.dispose();
    _pitchDetector.dispose();
    super.dispose();
  }

  void startRecord(String recordPath) {
    _audioSink = File(recordPath).openWrite();
    _recordStart = DateTime.now();
    // add empty header
    _audioSink!.add(
      AudioUtils.pcm16wavHeader(
        0,
        numChannels,
        PitchDetector.DEFAULT_SAMPLE_RATE,
      ),
    );
  }

  Future<void> stopRecord(String recordPath) async {
    await _audioSink!.flush();
    await _audioSink!.close();
    _audioSink = null;
    // replace with updated header
    final raf = await File(recordPath).open(mode: FileMode.append);
    await raf.setPosition(0);
    await raf.writeFrom(
      AudioUtils.pcm16wavHeader(
        _dataSize,
        numChannels,
        PitchDetector.DEFAULT_SAMPLE_RATE,
      ),
    );
    await raf.flush();
    await raf.close();
  }

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 10,
        children: [
          Expanded(
            child: Material(
              elevation: 2,
              borderRadius: BorderRadius.circular(10),
              color: ColorScheme.of(context).surfaceContainerLow,
              child: Padding(padding: EdgeInsets.all(10), child: PitchChart()),
            ),
          ),
        ],
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: RecordBtn(
          key: ValueKey(_recording),
          recording: _recording,
          recordDuration: _recording
              ? DateTime.now().difference(_recordStart)
              : Duration.zero,
          onPressed: () async {
            // start record
            if (_recording && _audioSink != null) {
              setState(() {
                _recording = false;
              });
              await stopRecord(_recordPath);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Recorded at $_recordPath"),
                    elevation: 2,
                    action: SnackBarAction(
                      label: "Open",
                      onPressed: () async {
                        await OpenFile.open(_recordPath, linuxUseGio: false);
                      },
                    ),
                  ),
                );
              }
            } else if (!_recording) {
              final saveDir = await getApplicationSupportDirectory();
              _recordPath = path.join(
                saveDir.path,
                AudioUtils.getAudioFileName(),
              );
              _dataSize = 0;
              setState(() {
                startRecord(_recordPath); // add empty header
                _recording = true;
              });
            }
          },
        ),
      ),
    ];

    return Stack(alignment: Alignment.bottomRight, children: children);
  }
}
