import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guitar_buddy/models/song.dart';
import 'package:guitar_buddy/providers/song_view_provider.dart';
import 'package:guitar_buddy/widgets/song_content.dart';
import 'package:guitar_buddy/widgets/song_view_setting_dialog.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class SongViewPage extends StatelessWidget {
  const SongViewPage({super.key, required this.song});

  final CompleteSong song;

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
          children: [Expanded(child: SongContent(song: song))],
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
