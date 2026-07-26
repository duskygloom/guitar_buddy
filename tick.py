import wave
import struct
import math

SAMPLE_RATE = 44100
DURATION = 0.05
FREQUENCY = 2200
AMPLITUDE = 1.0

OUTPUT_FILE = "assets/audio/tick.wav"


def generate_tick():
    num_samples = int(SAMPLE_RATE * DURATION)

    with wave.open(OUTPUT_FILE, "wb") as wav:
        wav.setnchannels(1)        # Mono
        wav.setsampwidth(2)        # 16-bit PCM
        wav.setframerate(SAMPLE_RATE)

        frames = []

        for i in range(num_samples):
            t = i / SAMPLE_RATE

            # Exponential decay envelope
            envelope = math.exp(-60 * t)

            sample = (
                0.7 * math.sin(2 * math.pi * 1800 * t) +
                0.3 * math.sin(2 * math.pi * 3600 * t) +
                0.15 * math.sin(2 * math.pi * 5400 * t)
                # 0.60 * math.sin(2 * math.pi * 1500 * t) +
                # 0.35 * math.sin(2 * math.pi * 2450 * t) +
                # 0.20 * math.sin(2 * math.pi * 3900 * t) +
                # 0.10 * math.sin(2 * math.pi * 5600 * t)
            )

            sample *= envelope * AMPLITUDE

            

            frames.append(struct.pack("<h", int(sample * 32767)))

        wav.writeframes(b"".join(frames))

    print(f"Generated {OUTPUT_FILE}")


if __name__ == "__main__":
    generate_tick()