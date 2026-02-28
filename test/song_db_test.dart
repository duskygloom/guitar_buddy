import 'package:flutter/foundation.dart';
import 'package:guitar_buddy/data/song_data.dart';
import 'package:guitar_buddy/models/db_utils.dart';
import 'package:guitar_buddy/models/song.dart';

Future<void> main() async {
  final db = await DButils.getDB();
  try {
    final songs = SongData.sampleSongs;
    final List<Song?> completeSongs = [];
    for (final song in songs) {
      completeSongs.add(await Song.store(song));
    }
    for (final song in completeSongs) {
      if (song == null) {
        if (kDebugMode) {
          print("Failed to store a song.");
        }
      }
    }
  } finally {
    await db.close();
  }
}
