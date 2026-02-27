import 'dart:math';

class PitchCalculator {
  static String? pitchToNote(double pitch, {bool useFlats = false}) {
    if (pitch <= 0) return null;
    final midi = _midiFromPitch(pitch);
    const sharps = [
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
    const flats = ["C", "Db", "D", "Eb", "F", "Gb", "G", "Ab", "Bb", "B"];
    final note = useFlats
        ? flats[midi.round() % 12]
        : sharps[midi.round() % 12];
    final octave = (midi / 12).floor() - 1;
    return "$note$octave";
  }

  static int _midiFromPitch(double frequency) {
    final noteNum = 12.0 * (log((frequency / 440.0)) / log(2.0));
    return (noteNum.roundToDouble() + 69.0).toInt();
  }
}
