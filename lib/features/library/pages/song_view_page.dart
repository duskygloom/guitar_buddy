import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:guitar_buddy/features/library/models/song.dart';
import 'package:guitar_buddy/features/library/providers/song_view_prov.dart';
import 'package:guitar_buddy/features/library/utils/db_utils.dart';
import 'package:guitar_buddy/features/library/widgets/song_content.dart';
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
            tooltip: "Copy song",
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: song.content));
            },
            icon: Icon(Symbols.content_copy_rounded),
          ),
          SizedBox(width: 5),
          _AutoscrollButton(),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: Consumer(
            builder: (context, ref, child) {
              final numColumns = ref.watch(songViewConfigProv).columns;
              final columns = <Widget>[];
              for (int i = 0; i < numColumns; i++) {
                if (i > 0) {
                  columns.add(VerticalDivider(width: 10));
                }
                columns.add(
                  Expanded(
                    child: Column(
                      spacing: 10,
                      children: [Expanded(child: SongContent(song: song))],
                    ),
                  ),
                );
              }
              return Row(children: columns);
            },
          ),
        ),
      ),
      floatingActionButton: Consumer(
        builder: (context, ref, child) => AnimatedSlide(
          duration: Duration(milliseconds: 200),
          offset:
              ref.watch(songViewConfigProv).autoScrolling ||
                  ref.watch(songViewConfigProv).scrolling
              ? Offset(1.5, 0)
              : Offset.zero,
          curve: Curves.easeInOutCirc,
          child: _ViewFloatingButton(),
        ),
      ),
      bottomNavigationBar: _ViewSettings(song.id),
    );
  }
}

class _ViewSettings extends ConsumerWidget {
  const _ViewSettings(this.songId);

  final String songId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void updateSettings() {
      DButils.modifySettings(
        songId,
        transpose: ref.read(songViewConfigProv).transpose,
        scrollSpeed: ref.read(songViewConfigProv).scrollSpeed,
      ).then((_) {});
    }

    final List<Widget> items = [
      _NumberInputTile(
        title: "Transpose",
        value: "${ref.watch(songViewConfigProv).transpose}",
        addFunction: () {
          ref.read(songViewConfigProv.notifier).transposeUp;
          updateSettings();
        },
        removeFunction: () {
          ref.read(songViewConfigProv.notifier).transposeDown;
          updateSettings();
        },
      ),
      _NumberInputTile(
        title: "Scroll speed",
        value: "${ref.watch(songViewConfigProv).scrollSpeed}",
        addFunction: () {
          ref.read(songViewConfigProv.notifier).speedUp;
          updateSettings();
        },
        removeFunction: () {
          ref.read(songViewConfigProv.notifier).speedDown;
          updateSettings();
        },
        addIcon: Symbols.fast_forward_rounded,
        removeIcon: Symbols.fast_rewind_rounded,
      ),
      _NumberInputTile(
        title: "Columns",
        value: "${ref.watch(songViewConfigProv).columns}",
        addFunction: ref.read(songViewConfigProv.notifier).columnsIncr,
        removeFunction: ref.read(songViewConfigProv.notifier).columnsDecr,
      ),
      _NumberInputTile(
        title: "Font size",
        value: "${ref.watch(songViewConfigProv).fontSize}",
        addFunction: ref.read(songViewConfigProv.notifier).fontSizeUp,
        removeFunction: ref.read(songViewConfigProv.notifier).fontSizeDown,
        addIcon: Symbols.zoom_in_rounded,
        removeIcon: Symbols.zoom_out_rounded,
      ),
    ];

    return ref.watch(songViewConfigProv).showSettings
        ? Container(
            height: 100,
            color: ColorScheme.of(context).surfaceContainer,
            padding: EdgeInsets.symmetric(horizontal: 20),
            alignment: Alignment.center,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              itemBuilder: (context, index) => items[index],
              separatorBuilder: (context, index) => VerticalDivider(
                width: 40,
                thickness: 2,
                radius: BorderRadius.circular(1000),
                indent: 30,
                endIndent: 30,
              ),
              itemCount: items.length,
            ),
          )
        : SizedBox.shrink();
  }
}

class _ViewFloatingButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FloatingActionButton(
      tooltip: "Toggle settings",
      onPressed: ref.read(songViewConfigProv.notifier).toggleSettings,
      child: Text(
        "${ref.watch(songViewConfigProv).transpose}",
        style: GoogleFonts.sen(fontSize: 25, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _NumberInputTile extends StatelessWidget {
  const _NumberInputTile({
    required this.title,
    required this.value,
    required this.addFunction,
    required this.removeFunction,
    this.addIcon,
    this.removeIcon,
  });

  final String title, value;
  final Function addFunction, removeFunction;
  final IconData? addIcon, removeIcon;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          spacing: 10,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton.filledTonal(
              onPressed: () {
                removeFunction();
              },
              icon: Icon(removeIcon ?? Symbols.remove_rounded),
            ),
            SizedBox(
              width: 60,
              child: TextField(
                enabled: false,
                textAlign: TextAlign.center,
                controller: TextEditingController(text: value),
              ),
            ),
            IconButton.filledTonal(
              onPressed: () {
                addFunction();
              },
              icon: Icon(addIcon ?? Symbols.add_rounded),
            ),
          ],
        ),
        Text(title),
      ],
    );
  }
}

class _AutoscrollButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton.filledTonal(
      tooltip: "Autoscroll",
      onPressed: ref.read(songViewConfigProv.notifier).toggleAutoscroll,
      icon: Icon(
        ref.watch(songViewConfigProv).autoScrolling
            ? Symbols.pause_rounded
            : Symbols.play_arrow_rounded,
      ),
    );
  }
}
