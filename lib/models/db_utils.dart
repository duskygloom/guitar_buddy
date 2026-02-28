import 'package:guitar_buddy/models/date_time_utils.dart';
import 'package:guitar_buddy/models/song.dart';
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
          "id integer primary key autoincrement, "
          "title text not null, "
          "artist text not null, "
          "uploadedOn text, "
          "modifiedOn text)";
      await db.execute(songsTableQuery);
      // table containing song specific settings
      final songSettingsTableQuery =
          "create table if not exists songSettings ("
          "id integer primary key, "
          "transpose integer, "
          "scrollSpeed real)";
      await db.execute(songSettingsTableQuery);
    } catch (e) {
      throw Exception("failed to open database");
    } finally {
      await db.close();
    }
  }

  static Future<String> insertSong(Song song, {String? songId}) async {
    final db = await DButils.getDB();

    try {
      final int newId;
      final DateTime uploadedOn;
      final now = DateTime.now();
      final modifiedOn = DateTimeUtils.format(now);

      // fresh insert
      if (songId == null) {
        newId = await db.insert("songs", {
          "title": song.title,
          "artist": song.artist,
          "uploadedOn": modifiedOn,
          "modifiedOn": modifiedOn,
        });
        uploadedOn = now;
        // insert settings too
        await db.insert("songSettings", {
          "id": newId,
          "transpose": 0,
          "scrollSpeed": 1.0,
        });
      }
      // modify
      else {
        final (id, _) = Song.parseCompleteId(songId);
        final results = await db.query(
          "songs",
          where: "id = ?",
          whereArgs: [id],
        );
        if (results.isEmpty) {
          throw Exception("song does not exist");
        } else {
          final songRecord = results.first;
          uploadedOn = DateTimeUtils.parse(songRecord["uploadedOn"] as String);
          await db.update(
            "songs",
            {
              "title": song.title,
              "artist": song.artist,
              "modifiedOn": modifiedOn,
            },
            where: "id = ?",
            whereArgs: [id],
          );
          newId = id;
        }
      }
      return Song.getCompleteId(newId, uploadedOn);
    } catch (e) {
      throw Exception("could not insert song");
    } finally {
      await db.close();
    }
  }

  /// Returns the number of rows affected.
  static Future<int> deleteSong(CompleteSong song) async {
    final db = await getDB();
    try {
      final (id, _) = Song.parseCompleteId(song.id);
      int affected = await db.delete("songs", where: "id = ?", whereArgs: [id]);
      affected += await db.delete(
        "songSettings",
        where: "id = ?",
        whereArgs: [id],
      );
      return affected;
    } finally {
      await db.close();
    }
  }

  static Future<List<Map<String, Object?>>> fetchAllSongs() async {
    final db = await getDB();
    final results = await db.rawQuery(
      "select * from songs natural join songSettings "
      "order by title, artist",
    );
    return results;
  }

  static Future<int> modifySettings(
    String songId, {
    int transpose = 0,
    double scrollSpeed = 1.0,
  }) async {
    final db = await DButils.getDB();
    try {
      final int newId;
      final (id, _) = Song.parseCompleteId(songId);
      final results = await db.query(
        "songSettings",
        where: "id = ?",
        whereArgs: [id],
      );
      if (results.isEmpty) {
        // new song setting
        throw Exception("song setting does not exist");
      } else {
        // update existing setting
        newId = await db.update(
          "songSettings",
          {"transpose": transpose, "scrollSpeed": scrollSpeed},
          where: "id = ?",
          whereArgs: [id],
        );
      }
      return newId;
    } catch (e) {
      throw Exception("could not modify song setting");
    } finally {
      await db.close();
    }
  }

  static Future<Map<String, Object?>> fetchSettingOf(String songId) async {
    final db = await DButils.getDB();
    try {
      final (id, _) = Song.parseCompleteId(songId);
      final results = await db.query(
        "songSettings",
        where: "id = ?",
        whereArgs: [id],
      );
      if (results.isEmpty) {
        return {};
      }
      return results.first;
    } catch (e) {
      throw Exception("could not insert setting");
    } finally {
      await db.close();
    }
  }
}
