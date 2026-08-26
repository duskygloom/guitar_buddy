import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guitar_buddy/main_theme.dart';
import 'package:guitar_buddy/features/library/providers/library_prov.dart';
import 'package:guitar_buddy/features/library/providers/new_song_prov.dart';
import 'package:guitar_buddy/features/library/widgets/library_toolbar.dart';
import 'package:guitar_buddy/features/library/widgets/song_library.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Guitar Buddy")),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            HomeToolbar(),
            SizedBox(height: 20),
            AppBar(
              title: Text("Library"),
              centerTitle: false,
              forceMaterialTransparency: true,
            ),
            Expanded(child: SongLibrary()),
          ],
        ),
      ),
      floatingActionButton: Consumer(
        builder: (context, ref, child) {
          return AnimatedScale(
            duration: Duration(milliseconds: 400),
            scale: ref.watch(libraryScrollingProv) ? 0.0 : 1.0,
            curve: Curves.easeInOutCirc,
            child: _ActionButton(),
          );
        },
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) => FloatingActionButton(
        onPressed: () async {
          await Future.delayed(MainTheme.clickDelay);
          ref.read(newSongTitleProv).text = "";
          ref.read(newSongArtistProv).text = "";
          ref.read(newSongContentProv).text = "";
          if (context.mounted) {
            Navigator.pushNamed(context, "/new");
          }
        },
        tooltip: "New song",
        child: Icon(Symbols.add_rounded),
      ),
    );
  }
}
