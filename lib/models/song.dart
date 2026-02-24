import 'dart:convert';
import 'dart:io';

import 'package:guitar_buddy/models/database.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class Song {
  const Song({
    required this.title,
    required this.artist,
    required this.content,
    this.uploadedOn,
    this.modifiedOn,
  });

  final String title, artist, content;
  final DateTime? uploadedOn, modifiedOn;

  String? get id {
    if (uploadedOn == null) {
      return null;
    }
    return base64Encode(
      utf8.encode("$title-$artist-${DButils.dbDateFormat.format(uploadedOn!)}"),
    );
  }

  static Future<Song> store(Song song) async {
    song = await DButils.insertNewSong(song);
    if (song.id != null) {
      final appDir = await getApplicationSupportDirectory();
      final songPath = path.join(appDir.path, "songs");
      var songDir = Directory(songPath);
      if (!songDir.existsSync()) {
        songDir = await songDir.create();
      }
      var songFile = File(path.join(songPath, song.id!));
      songFile = await songFile.writeAsString(song.content);
    }
    return song;
  }

  static Stream<Song> fetchAll() async* {}
}
