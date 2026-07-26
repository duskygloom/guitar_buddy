import 'package:guitar_buddy/features/pitch_monitor/utils/pitch_utils.dart';

class Pitch {
  final DateTime time;
  final double frequency;

  Pitch(this.time, this.frequency);

  @override
  String toString() {
    final note = PitchUtils.pitchToNote(frequency);
    if (note.isNaN || note.isInfinite) {
      return "$note";
    } else {
      return "${note.round()}";
    }
  }
}
