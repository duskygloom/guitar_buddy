import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guitar_buddy/providers/home_page_provider.dart';
import 'package:guitar_buddy/providers/new_song_provider.dart';
import 'package:guitar_buddy/widgets/home_toolbar.dart';
import 'package:guitar_buddy/widgets/song_library.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
        builder: (context, ref, child) => AnimatedSlide(
          duration: Duration(milliseconds: 200),
          offset: ref.watch(libraryScrollingProvider)
              ? Offset(1.5, 0)
              : Offset.zero,
          curve: Curves.easeInOutCirc,
          child: _ActionButton(),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) => FloatingActionButton(
        onPressed: () {
          ref.read(newSongTitleProvider).text = "";
          ref.read(newSongArtistProvider).text = "";
          ref.read(newSongContentProvider).text = "";
          Navigator.pushNamed(context, "/new");
        },
        tooltip: "New song",
        child: Icon(Symbols.add_rounded),
      ),
    );
  }
}
