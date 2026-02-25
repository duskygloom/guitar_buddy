import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guitar_buddy/models/chord_parser.dart';
import 'package:guitar_buddy/models/song.dart';
import 'package:guitar_buddy/providers/song_view_provider.dart';

class SongContent extends ConsumerStatefulWidget {
  const SongContent({super.key, required this.song});

  final Song song;

  @override
  ConsumerState<SongContent> createState() => _SongContentState();
}

class _SongContentState extends ConsumerState<SongContent> {
  double fontSize = kDefaultFontSize;
  double oldFontSize = kDefaultFontSize;

  final scroller = ScrollController();
  Timer? scrollTimer;

  @override
  void initState() {
    super.initState();
    fontSize = ref.read(fontSizeProvider);
  }

  @override
  void dispose() {
    scroller.dispose();
    scrollTimer?.cancel();
    super.dispose();
  }

  void _startScrolling() {
    if (scrollTimer != null) {
      scrollTimer!.cancel();
    }
    scrollTimer = Timer.periodic(Duration(milliseconds: 100), (timer) async {
      if (scroller.hasClients) {
        final speed = ref.read(speedProvider);
        final maxPosition = scroller.position.maxScrollExtent;
        final currPosition = scroller.offset;
        if (currPosition < maxPosition) {
          await scroller.animateTo(
            currPosition + speed,
            duration: Duration(milliseconds: 90),
            curve: Curves.linear,
          );
        } else {
          _stopScrolling();
        }
      } else {
        _stopScrolling();
      }
    });
  }

  void _stopScrolling() {
    scrollTimer?.cancel();
    ref.read(scrollingProvider.notifier).state = false;
  }

  @override
  Widget build(BuildContext context) {
    final scrolling = ref.watch(scrollingProvider);
    final transpose = ref.watch(transposeProvider);
    final tokens = ChordParser.parse(widget.song.content);

    if (scrolling) {
      _startScrolling();
    } else {
      _stopScrolling();
    }

    return GestureDetector(
      onScaleStart: (details) {
        oldFontSize = fontSize;
      },
      onScaleUpdate: (details) {
        final size = (details.scale * oldFontSize)
            .clamp(10.0, 40.0)
            .roundToDouble();
        setState(() {
          fontSize = size;
        });
      },
      onScaleEnd: (details) {
        ref.read(fontSizeProvider.notifier).state = fontSize;
      },
      onTap: () {
        // scale update stops working sometimes
        // (likely due to change in focus)
        // tap event somehow makes it work again
      },
      child: SingleChildScrollView(
        controller: scroller,
        child: Align(
          alignment: Alignment.topCenter,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.song.title, style: TextStyle(fontSize: fontSize + 8)),
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
    );
  }
}
