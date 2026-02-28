import 'dart:io';

import 'package:guitar_buddy/models/date_time_utils.dart';
import 'package:guitar_buddy/models/db_utils.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class Song {
  const Song({
    required this.title,
    required this.artist,
    required this.content,
  });

  final String title, artist, content;

  static String getCompleteId(int id, DateTime uploadedOn) {
    final dateString = DateTimeUtils.format(uploadedOn);
    final idString = id.toString().padLeft(6, "0");
    return "$dateString-$idString";
  }

  static (int, DateTime) parseCompleteId(String completeId) {
    final parts = completeId.split("-");
    final uploadedOn = DateTimeUtils.parse(parts[0]);
    final id = int.parse(parts[1]);
    return (id, uploadedOn);
  }

  static Future<Directory> fetchSongDir() async {
    final appDir = await getApplicationSupportDirectory();
    final songPath = path.join(appDir.path, "songs");
    return Directory(songPath);
  }

  static Future<Song> store(Song song, {String? songId}) async {
    final String completeId = await DButils.insertSong(song, songId: songId);
    final songDir = await fetchSongDir();
    if (!songDir.existsSync()) {
      await songDir.create();
    }
    final songFile = File(path.join(songDir.path, completeId));
    await songFile.writeAsString(song.content);
    return song;
  }

  static Future<List<CompleteSong>> fetchAll() async {
    final results = await DButils.fetchAllSongs();
    final List<CompleteSong> songs = [];

    for (final result in results) {
      final completeSong = await CompleteSong.fetchFromRecord(result);
      songs.add(completeSong);
    }
    return songs;
  }
}

class CompleteSong extends Song {
  const CompleteSong({
    required this.id,
    required super.title,
    required super.artist,
    required super.content,
    required this.uploadedOn,
    required this.modifiedOn,
    required this.transpose,
    required this.scrollSpeed,
  });

  final String id;
  final DateTime uploadedOn, modifiedOn;
  final int transpose;
  final double scrollSpeed;

  static Future<CompleteSong> fetchFromRecord(
    Map<String, Object?> record,
  ) async {
    final uploadedOn = DateTimeUtils.parse(record["uploadedOn"]! as String);
    final modifiedOn = DateTimeUtils.parse(record["modifiedOn"]! as String);

    final completeId = Song.getCompleteId(record["id"] as int, uploadedOn);

    final songDir = await Song.fetchSongDir();
    final contentFile = File(path.join(songDir.path, completeId));
    final String content;
    if (contentFile.existsSync()) {
      content = await contentFile.readAsString();
    } else {
      content = "";
    }

    return CompleteSong(
      id: completeId,
      title: record["title"]! as String,
      artist: record["artist"]! as String,
      content: content,
      uploadedOn: uploadedOn,
      modifiedOn: modifiedOn,
      transpose: (record["transpose"] as int?) ?? 0,
      scrollSpeed: (record["scrollSpeed"] as double?) ?? 1.0,
    );
  }
}
