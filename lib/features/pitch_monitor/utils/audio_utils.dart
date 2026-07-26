import 'dart:math' as math;
import 'dart:typed_data';

class AudioUtils {
  static String getAudioFileName() {
    String padInt(int n, int width) {
      if (width == 2 && n < 10) {
        return "0$n";
      } else if (width == 2) {
        return n.toString();
      } else {
        int numDigits = (math.log(n) / math.log(10)).floor() + 1;
        return "0" * (width - numDigits) + n.toString();
      }
    }

    final currentTime = DateTime.now();
    return "${currentTime.year}${padInt(currentTime.month, 2)}"
        "${padInt(currentTime.day, 2)}${padInt(currentTime.hour, 2)}"
        "${padInt(currentTime.minute, 2)}${padInt(currentTime.second, 2)}.wav";
  }

  static Uint8List pcm16wavHeader(
    int dataSize,
    int numChannels,
    int sampleRate,
  ) {
    final builder = BytesBuilder();

    void writeString(String s) {
      builder.add(s.codeUnits);
    }

    void writeUint16(int value) {
      final b = ByteData(2);
      b.setUint16(0, value, Endian.little);
      builder.add(b.buffer.asUint8List());
    }

    void writeUint32(int value) {
      final b = ByteData(4);
      b.setUint32(0, value, Endian.little);
      builder.add(b.buffer.asUint8List());
    }

    const bitsPerSample = 16;

    writeString("RIFF");
    writeUint32(dataSize + 44); // 44 is the size of the header
    writeString("WAVE");
    writeString("fmt ");
    writeUint32(16); // size of the format till now
    writeUint16(1); // 1 for PCM
    writeUint16(numChannels);
    writeUint32(sampleRate);
    writeUint32(sampleRate * numChannels * bitsPerSample ~/ 8); // byte rate
    writeUint16(bitsPerSample * numChannels ~/ 8); // byte per sample
    writeUint16(bitsPerSample);
    writeString("data");
    writeUint32(dataSize);

    return builder.toBytes();
  }
}
