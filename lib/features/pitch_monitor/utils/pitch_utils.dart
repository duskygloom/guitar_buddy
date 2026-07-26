import 'dart:math' as math;

class PitchUtils {
  static const notes = [
    "C",
    "C#",
    "D",
    "D#",
    "E",
    "F",
    "F#",
    "G",
    "G#",
    "A",
    "A#",
    "B",
  ];

  static double pitchToNote(double pitch) {
    return 12 * math.log(pitch / 440) / math.log(2) + 69;
  }

  static String noteToString(double note) {
    return "${notes[note.round() % 12]}${note.round() ~/ 12 - 1}";
  }

  static T? computeMedian<T>(
    List<T> data,
    double Function(T element) keyFunction,
  ) {
    data.sort((a, b) {
      return keyFunction(a).compareTo(keyFunction(b));
    });
    if (data.isNotEmpty) return data[data.length ~/ 2];
    return null;
  }
}
