import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:guitar_buddy/features/metronome/widgets/bpm_ctrl.dart';
import 'package:guitar_buddy/features/metronome/widgets/bpm_display.dart';
import 'package:guitar_buddy/features/metronome/providers/bpm_provider.dart';

class MetronomePage extends ConsumerStatefulWidget {
  const MetronomePage({super.key});

  @override
  ConsumerState<MetronomePage> createState() => _MetronomePageState();
}

class _MetronomePageState extends ConsumerState<MetronomePage>
    with SingleTickerProviderStateMixin {
  final _player = AudioPlayer();
  Timer? _timer;

  bool playing = false;

  late final AnimationController _pulseController = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: 200),
    lowerBound: 0.25,
    upperBound: 0.75,
  );

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
    _player.dispose();
  }

  Future<void> _tick() async {
    _pulseController.forward(from: 0.25);
    await _player.stop();
    await _player.play(AssetSource('audio/tick.wav'));
  }

  void start() {
    _tick();

    final bpm = ref.read(bpmProvider);
    final beatDuration = Duration(milliseconds: (60000 / bpm).round());
    _timer = Timer.periodic(beatDuration, (_) => _tick());

    setState(() {
      playing = true;
    });
  }

  void stop() {
    _timer?.cancel();
    setState(() {
      playing = false;
    });
  }

  static const minBpm = 40;
  static const maxBpm = 240;

  void changeBpm(double value) {
    ref.read(bpmProvider.notifier).updateBpm(value.round());
    if (playing) {
      stop();
      start();
    }
  }

  void bpmIncrement() {
    ref.read(bpmProvider.notifier).increment();
    if (playing) {
      stop();
      start();
    }
  }

  void bpmDecrement() {
    ref.read(bpmProvider.notifier).decrement();
    if (playing) {
      stop();
      start();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bpm = ref.watch(bpmProvider);

    return Scaffold(
      appBar: AppBar(title: Text("Metronome")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 40,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                FadeTransition(
                  opacity: _pulseController,
                  child: Container(
                    width: (kDefaultFontSize + 2) * 12,
                    height: (kDefaultFontSize + 2) * 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: ColorScheme.of(context).primary,
                        width: 4,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: kDefaultFontSize * 12,
                  width: kDefaultFontSize * 12,
                  child: Material(
                    borderRadius: BorderRadius.circular(1000),
                    elevation: 4,
                    child: IconButton.filled(
                      iconSize: kDefaultFontSize * 3.5,
                      onPressed: () {
                        playing ? stop() : start();
                      },
                      icon: Icon(
                        weight: 700,
                        playing
                            ? Symbols.pause_rounded
                            : Symbols.play_arrow_rounded,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            BpmDisplay(
              bpm: bpm,
              bpmDecrementFunc: bpmDecrement,
              bpmIncrementFunc: bpmIncrement,
            ),
            BpmCtrl(
              bpm: bpm,
              minBpm: minBpm,
              maxBpm: maxBpm,
              onBpmChanged: changeBpm,
            ),
          ],
        ),
      ),
    );
  }
}
