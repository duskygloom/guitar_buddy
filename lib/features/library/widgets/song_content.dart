import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guitar_buddy/features/tuner/models/chord_parser.dart';
import 'package:guitar_buddy/features/library/models/song.dart';
import 'package:guitar_buddy/features/library/providers/song_view_prov.dart';

class SongContent extends ConsumerStatefulWidget {
  const SongContent({super.key, required this.song});

  final CompleteSong song;

  @override
  ConsumerState<SongContent> createState() => _SongContentState();
}

class _SongContentState extends ConsumerState<SongContent> {
  double oldFontSize = kDefaultFontSize;

  final scroller = ScrollController();
  Timer? scrollTimer;

  @override
  void dispose() {
    scroller.dispose();
    scrollTimer?.cancel();
    super.dispose();
  }

  void _startAutoscroll() {
    if (scrollTimer != null) {
      scrollTimer!.cancel();
    }
    scrollTimer = Timer.periodic(Duration(milliseconds: 100), (timer) async {
      if (scroller.hasClients) {
        final speed = ref.read(songViewConfigProv).scrollSpeed;
        final maxPosition = scroller.position.maxScrollExtent;
        final currPosition = scroller.offset;
        if (currPosition + speed < maxPosition) {
          await scroller.animateTo(
            currPosition + speed,
            duration: Duration(milliseconds: 100),
            curve: Curves.linear,
          );
        } else {
          _stopAutoscroll();
        }
      } else {
        _stopAutoscroll();
      }
    });
  }

  void _stopAutoscroll() {
    scrollTimer?.cancel();
    ref.read(songViewConfigProv.notifier).stopScrolling();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = ChordParser.parse(widget.song.content);

    final fontSize = ref.watch(songViewConfigProv).fontSize;
    final transpose = ref.watch(songViewConfigProv).transpose;

    ref.listen(songViewConfigProv, (old, curr) {
      if (mounted && old?.autoScrolling != curr.autoScrolling) {
        if (curr.autoScrolling) {
          _startAutoscroll();
        } else {
          _stopAutoscroll();
        }
      }
    });

    return GestureDetector(
      onScaleStart: (details) {
        oldFontSize = fontSize;
      },
      onScaleUpdate: (details) {
        final size = (details.scale * oldFontSize)
            .clamp(SongViewConfig.minFontSize, SongViewConfig.maxFontSize)
            .roundToDouble();
        ref.read(songViewConfigProv.notifier).setFontSize(size);
      },
      onTap: () {
        // scale update stops working sometimes
        // (likely due to change in focus)
        // tap event somehow makes it work again
      },
      child: NotificationListener<UserScrollNotification>(
        onNotification: (notification) {
          if (notification.direction == ScrollDirection.reverse) {
            ref.read(songViewConfigProv.notifier).startScrolling();
          }
          if (notification.direction == ScrollDirection.forward) {
            ref.read(songViewConfigProv.notifier).stopScrolling();
          }
          return true;
        },
        child: SingleChildScrollView(
          controller: scroller,
          child: Align(
            alignment: Alignment.topCenter,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.song.title,
                  style: TextStyle(fontSize: fontSize + 8),
                ),
                Text(
                  widget.song.artist,
                  style: TextStyle(
                    fontSize: fontSize + 2,
                    color: ColorScheme.of(context).onSurface.withAlpha(220),
                  ),
                ),
                Text("\n"),
                RichText(
                  text: TextSpan(
                    children: List.generate(tokens.length, (index) {
                      return TextSpan(
                        text: (tokens[index] + transpose).toString(),
                        style: tokens[index].isChord
                            ? TextTheme.of(context).bodyLarge?.copyWith(
                                fontSize: fontSize,
                                fontWeight: FontWeight.bold,
                                color: ColorScheme.of(context).tertiary,
                              )
                            : TextTheme.of(
                                context,
                              ).bodyLarge?.copyWith(fontSize: fontSize),
                      );
                    }),
                  ),
                ),
                Text("\n\n"),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
