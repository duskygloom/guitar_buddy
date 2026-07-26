import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:guitar_buddy/features/library/models/song.dart';
import 'package:guitar_buddy/features/library/providers/song_view_prov.dart';
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
      floatingActionButton: Consumer(
        builder: (context, ref, child) => AnimatedSlide(
          duration: Duration(milliseconds: 200),
          offset: ref.watch(svSongScrollingProv) || ref.watch(svScrollingProv)
              ? Offset(1.5, 0)
              : Offset.zero,
          curve: Curves.easeInOutCirc,
          child: _ViewFloatingButton(),
        ),
      ),
      bottomNavigationBar: _ViewSettings(),
    );
  }
}

class _ViewSettings extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<Widget> items = [
      _NumberInputTile(
        title: "Transpose",
        value: "${ref.watch(svTransposeProv)}",
        addFunction: () {
          if (ref.read(svTransposeProv) < svMaxTranspose) {
            ref.read(svTransposeProv.notifier).state++;
          }
        },
        removeFunction: () {
          if (ref.read(svTransposeProv) > svMinTranspose) {
            ref.read(svTransposeProv.notifier).state--;
          }
        },
      ),
      _NumberInputTile(
        title: "Scroll speed",
        value: "${ref.watch(svScrollSpeedProv)}",
        addFunction: () {
          if (ref.read(svScrollSpeedProv) < svMaxSpeed) {
            ref.read(svScrollSpeedProv.notifier).state += 0.5;
          }
        },
        removeFunction: () {
          if (ref.read(svScrollSpeedProv) > svMinSpeed) {
            ref.read(svScrollSpeedProv.notifier).state -= 0.5;
          }
        },
        addIcon: Symbols.fast_forward_rounded,
        removeIcon: Symbols.fast_rewind_rounded,
      ),
      _NumberInputTile(
        title: "Font size",
        value: "${ref.watch(svFontSizeProv)}",
        addFunction: () {
          if (ref.read(svFontSizeProv) < svMaxFontSize) {
            ref.read(svFontSizeProv.notifier).state++;
          }
        },
        removeFunction: () {
          if (ref.read(svFontSizeProv) > svMinFontSize) {
            ref.read(svFontSizeProv.notifier).state--;
          }
        },
        addIcon: Symbols.zoom_in_rounded,
        removeIcon: Symbols.zoom_out_rounded,
      ),
    ];

    return ref.watch(svShowSettingsProv)
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
      child: Text(
        "${ref.watch(svTransposeProv)}",
        style: GoogleFonts.sen(fontSize: 25, fontWeight: FontWeight.bold),
      ),
      onPressed: () {
        ref.read(svShowSettingsProv.notifier).state = !ref.read(
          svShowSettingsProv,
        );
      },
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

class _ScrollButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scrolling = ref.watch(svScrollingProv);
    return IconButton.filledTonal(
      tooltip: "Autoscroll",
      onPressed: () {
        ref.read(svScrollingProv.notifier).state = !ref.read(svScrollingProv);
      },
      icon: Icon(
        scrolling ? Symbols.pause_rounded : Symbols.play_arrow_rounded,
      ),
    );
  }
}
