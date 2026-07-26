import 'package:guitar_buddy/features/pitch_monitor/models/pitch.dart';
import 'package:pitch_detector_dart/pitch_detector_result.dart';

// A sample is a list of pitch whose any two consecutive
// members are not farther than [PitchSamples.sampleTimeout]
typedef PitchSample = List<Pitch>;

class PitchStore {
  final PitchDetectorResult? lastPitchResult;
  final List<Pitch> pitches;

  // markers mark the end of each sample in [pitches] in increasing order
  final List<int> endMarkers;

  const PitchStore({
    required this.pitches,
    required this.endMarkers,
    this.lastPitchResult,
  });

  static const sampleTimeout = Duration(milliseconds: 250);

  List<PitchSample> get samples {
    final endMarkers = [0] + this.endMarkers;
    return List.generate(
      endMarkers.length - 1,
      (index) => pitches.sublist(endMarkers[index], endMarkers[index + 1]),
    );
  }
}
