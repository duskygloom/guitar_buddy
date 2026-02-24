import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guitar_buddy/models/chord_parser.dart';
import 'package:guitar_buddy/models/song.dart';
import 'package:guitar_buddy/providers/song_view_provider.dart';
import 'package:guitar_buddy/widgets/song_view_setting_dialog.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class SongViewPage extends StatelessWidget {
  const SongViewPage({super.key, required this.song});

  final Song song;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(song.title),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                DialogRoute(
                  context: context,
                  builder: (context) => SongViewSettingDialog(),
                ),
              );
            },
            icon: Icon(Symbols.settings_rounded),
          ),
          SizedBox(width: 5),
          _ScrollButton(),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          spacing: 10,
          children: [Expanded(child: _SongContent(song: song))],
        ),
      ),
    );
  }
}

class _ScrollButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scrolling = ref.watch(scrollingProvider);
    return IconButton.filledTonal(
      tooltip: "Scroll",
      onPressed: () {
        ref.read(scrollingProvider.notifier).state = !ref.read(
          scrollingProvider,
        );
      },
      icon: Icon(
        scrolling ? Symbols.pause_rounded : Symbols.play_arrow_rounded,
      ),
    );
  }
}

class _SongContent extends ConsumerStatefulWidget {
  const _SongContent({required this.song});

  final Song song;

  @override
  ConsumerState<_SongContent> createState() => _SongContentState();
}

class _SongContentState extends ConsumerState<_SongContent> {
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    scrollTimer?.cancel();
  }

  @override
  void dispose() {
    scroller.dispose();
    scrollTimer?.cancel();
    super.dispose();
  }

  void _startScrolling() {
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
