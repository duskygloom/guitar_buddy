import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guitar_buddy/data/song_data.dart';
import 'package:guitar_buddy/pages/song_view_page.dart';
import 'package:guitar_buddy/providers/song_view_provider.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class SongLibrary extends StatelessWidget {
  const SongLibrary({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: SongData.sampleSongs.length,
      itemBuilder: (context, index) => Consumer(
        builder: (context, ref, child) => ListTile(
          title: Text(SongData.sampleSongs[index].title),
          subtitle: Text(SongData.sampleSongs[index].artist),
          leading: Padding(
            padding: EdgeInsets.all(5),
            child: Icon(Symbols.music_note_rounded),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 10),
          trailing: PopupMenuButton(
            tooltip: "",
            borderRadius: BorderRadius.circular(100),
            iconSize: 40,
            clipBehavior: Clip.antiAlias,
            itemBuilder: (context) => [
              PopupMenuItem(
                child: Row(
                  spacing: 10,
                  children: [
                    Icon(Symbols.edit_rounded, size: 20),
                    Text("Edit"),
                  ],
                ),
              ),
              PopupMenuItem(
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
          ),
          onTap: () {
            // scroll speed and transpose should be set from
            // a local database, also store scroll speed and
            // transpose when changed
            ref.read(scrollingProvider.notifier).state = false;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    SongViewPage(song: SongData.sampleSongs[index]),
              ),
            );
          },
        ),
      ),
    );
  }
}
