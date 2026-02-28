import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guitar_buddy/models/db_utils.dart';
import 'package:guitar_buddy/models/song.dart';
import 'package:guitar_buddy/pages/new_song_page.dart';
import 'package:guitar_buddy/pages/song_view_page.dart';
import 'package:guitar_buddy/providers/home_page_provider.dart';
import 'package:guitar_buddy/providers/new_song_provider.dart';
import 'package:guitar_buddy/providers/song_view_provider.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class SongTile extends ConsumerWidget {
  const SongTile({super.key, required this.song});

  final CompleteSong song;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      title: Text(song.title),
      subtitle: Text(song.artist),
      leading: Padding(
        padding: EdgeInsets.all(5),
        child: Icon(Symbols.music_note_rounded),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 10),
      trailing: _MoreButton(song: song),
      onTap: () async {
        final setting = await DButils.fetchSettingOf(song.id);
        ref.read(scrollingProvider.notifier).state = false;
        ref.read(transposeProvider.notifier).state =
            setting["transpose"] == null ? 0 : setting["transpose"] as int;
        ref
            .read(scrollSpeedProvider.notifier)
            .state = setting["scrollSpeed"] == null
            ? 1.0
            : setting["scrollSpeed"] as double;
        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SongViewPage(song: song)),
          );
        }
      },
    );
  }
}

class _MoreButton extends ConsumerWidget {
  const _MoreButton({required this.song});

  final CompleteSong song;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton(
      borderRadius: BorderRadius.circular(100),
      iconSize: 40,
      clipBehavior: Clip.antiAlias,
      itemBuilder: (context) => [
        PopupMenuItem(
          onTap: () {
            ref.read(newSongTitleProvider).text = song.title;
            ref.read(newSongArtistProvider).text = song.artist;
            ref.read(newSongContentProvider).text = song.content;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NewSongPage(songId: song.id),
              ),
            );
          },
          child: Row(
            spacing: 10,
            children: [Icon(Symbols.edit_rounded, size: 20), Text("Edit")],
          ),
        ),
        PopupMenuItem(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text("Warning"),
                content: Text("Do you really want to delete this song?"),
                actions: [
                  TextButton(
                    onPressed: () async {
                      await DButils.deleteSong(song);
                      await ref
                          .watch(libraryRefreshKeyProvider)
                          .currentState
                          ?.show();
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    },
                    child: Text(
                      "Yes",
                      style: TextStyle(color: ColorScheme.of(context).error),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("No"),
                  ),
                ],
              ),
            );
          },
          child: Row(
            spacing: 10,
            children: [
              Icon(
                Symbols.delete_rounded,
                size: 20,
                color: ColorScheme.of(context).error,
              ),
              Text(
                "Delete",
                style: TextStyle(color: ColorScheme.of(context).error),
              ),
            ],
          ),
        ),
      ],
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Icon(Symbols.more_vert_rounded),
      ),
    );
  }
}
