import 'package:guitar_buddy/models/song.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DButils {
  static Future<Database> getDB() async {
    final appDir = await getApplicationSupportDirectory();
    final dbPath = path.join(appDir.path, "guitar_buddy.db");
    final db = await databaseFactoryFfi.openDatabase(dbPath);
    return db;
  }

  static Future<void> initDB() async {
    sqfliteFfiInit();
    final db = await DButils.getDB();
    try {
      // table containing songs
      final songsTableQuery =
          "create table if not exists songs ("
          "id text primary key, "
          "title text not null, "
          "artist text not null, "
          "uploadedOn text not null, "
          "modifiedOn text not null)";
      await db.execute(songsTableQuery);
      // table containing song specific settings
      final songSettingsTableQuery =
          "create table if not exists songSettings ("
          "id text primary key, "
          "transpose num, "
          "speed num)";
      await db.execute(songSettingsTableQuery);
    } finally {
      await db.close();
    }
  }

  static DateFormat dbDateFormat = DateFormat("yyyyMMddHHmmss");

  static Future<Song> insertNewSong(Song song) async {
    final db = await DButils.getDB();
    try {
      final now = DateTime.now();
      final modifiedOn = DButils.dbDateFormat.format(now);
      song = Song(
        title: song.title,
        artist: song.artist,
        content: song.content,
        uploadedOn: now,
        modifiedOn: now,
      );
      await db.insert("songs", {
        "id": song.id,
        "title": song.title,
        "artist": song.artist,
        "uploadedOn": modifiedOn,
        "modifiedOn": modifiedOn,
      });
      return song;
    } catch (e) {
      throw Exception("could not insert song");
    } finally {
      await db.close();
    }
  }

  static Future<List<Song>> fetchAllSongs() async {
    final db = await getDB();
    final results = await db.query("songs");
    print(results);
    return [];
  }
}
