import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guitar_buddy/models/song.dart';
import 'package:guitar_buddy/providers/home_page_provider.dart';
import 'package:guitar_buddy/widgets/song_tile.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class SongLibrary extends StatelessWidget {
  const SongLibrary({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Song.fetchAll(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final data = snapshot.data!;
          return _SongLibraryInstance(data);
        } else if (snapshot.hasError) {
          return Column(
            children: [
              AlertDialog(
                title: Text("Error", textAlign: TextAlign.center),
                content: Text(snapshot.error.toString()),
              ),
            ],
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}

class _SongLibraryInstance extends ConsumerStatefulWidget {
  const _SongLibraryInstance(this.songs);

  final List<CompleteSong> songs;

  @override
  ConsumerState<_SongLibraryInstance> createState() =>
      _SongLibraryInstanceState();
}

class _SongLibraryInstanceState extends ConsumerState<_SongLibraryInstance> {
  late List<CompleteSong> songs;

  @override
  void initState() {
    super.initState();
    songs = widget.songs;
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      key: ref.watch(libraryRefreshKeyProvider),
      onRefresh: () async {
        songs = await Song.fetchAll();
        setState(() {});
      },
      child: songs.isEmpty
          ? _EmptyList()
          : ListView.builder(
              itemCount: songs.length,
              itemBuilder: (context, index) => SongTile(song: songs[index]),
            ),
    );
  }
}

class _EmptyList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          onTap: () {
            Navigator.pushNamed(context, "/new");
          },
          title: Row(
            spacing: 10,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Icon(Symbols.add_rounded, size: 20), Text("Add song")],
          ),
          titleAlignment: ListTileTitleAlignment.center,
        ),
      ],
    );
  }
}
