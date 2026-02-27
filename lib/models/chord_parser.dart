class Token {
  const Token(this.text, {required this.isChord});

  final String text;
  final bool isChord;

  @override
  String toString() => text;

  static const flatNotes = [
    "A",
    "Bb",
    "B",
    "C",
    "Db",
    "D",
    "Eb",
    "E",
    "F",
    "Gb",
    "G",
    "Ab",
  ];

  static const sharpNotes = [
    "A",
    "A#",
    "B",
    "C",
    "C#",
    "D",
    "D#",
    "E",
    "F",
    "F#",
    "G",
    "G#",
  ];

  Token operator +(int value) {
    if (!isChord) return this;
    final noteRegex = RegExp(r"[A-G][#b]?");
    final match = noteRegex.firstMatch(text);
    if (match == null) return this;
    final note = text.substring(match.start, match.end);
    int noteIndex = sharpNotes.indexOf(note);
    if (noteIndex >= 0) {
      final nextNote = sharpNotes[(noteIndex + value) % 12];
      return Token(
        "${text.substring(0, match.start)}$nextNote${text.substring(match.end)}",
        isChord: isChord,
      );
    }
    noteIndex = flatNotes.indexOf(note);
    if (noteIndex >= 0) {
      final nextNote = flatNotes[(noteIndex + value) % 12];
      return Token("[$nextNote]", isChord: isChord);
    }
    return Token(text, isChord: isChord);
  }

  Token operator -(int value) {
    return this + (-value);
  }
}

class ChordParser {
  static List<Token> parse(String text) {
    final splitRegex = RegExp(r"\[[^\]]*\]");
    final chordRegex = RegExp(r"^\[[A-G][#b]?.*\]$");
    final List<Token> tokens = [];
    int start = 0;
    for (final match in splitRegex.allMatches(text)) {
      String lexeme = text.substring(start, match.start);
      tokens.add(Token(lexeme, isChord: false));
      lexeme = text.substring(match.start, match.end);
      tokens.add(Token(lexeme, isChord: chordRegex.hasMatch(lexeme)));
      start = match.end;
    }
    tokens.add(Token(text.substring(start), isChord: false));
    return tokens;
  }
}
