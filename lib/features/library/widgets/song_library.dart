import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guitar_buddy/features/library/models/song.dart';
import 'package:guitar_buddy/features/library/providers/library_prov.dart';
import 'package:guitar_buddy/features/library/widgets/song_tile.dart';
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
    final children = <Widget>[
      RefreshIndicator(
        key: ref.watch(libraryRefreshKeyProv),
        onRefresh: () async {
          songs = await Song.fetchAll();
          setState(() {});
        },
        child: ListView.builder(
          physics: AlwaysScrollableScrollPhysics(),
          itemCount: songs.length,
          itemBuilder: (context, index) => SongTile(song: songs[index]),
        ),
      ),
    ];
    if (songs.isEmpty) {
      children.add(_EmptyList());
    }

    return ScrollGestureDetector(
      child: Stack(alignment: Alignment.center, children: children),
      onScroll: () {
        ref.read(libraryScrollingProv.notifier).state = false;
      },
      onReverseScroll: () {
        if (songs.isEmpty) {
          ref.read(libraryScrollingProv.notifier).state = false;
        } else {
          ref.read(libraryScrollingProv.notifier).state = true;
        }
      },
    );
  }
}

class ScrollGestureDetector extends StatelessWidget {
  const ScrollGestureDetector({
    super.key,
    required this.child,
    required this.onScroll,
    required this.onReverseScroll,
  });

  final Widget child;
  final void Function() onScroll, onReverseScroll;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<UserScrollNotification>(
      onNotification: (notification) {
        if (notification.direction == ScrollDirection.reverse) {
          onReverseScroll();
        } else if (notification.direction == ScrollDirection.forward) {
          onScroll();
        }
        return false;
      },
      child: child,
    );
  }
}

class _EmptyList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorOfStuff = ColorScheme.of(context).onSurface.withAlpha(150);
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: kDefaultFontSize,
      children: [
        Icon(
          Symbols.vacuum_rounded,
          size: kDefaultFontSize * 3.5,
          color: colorOfStuff,
        ),
        Text(
          "Nothing here~",
          style: TextStyle(fontSize: kDefaultFontSize * 2, color: colorOfStuff),
        ),
      ],
    );
  }
}
