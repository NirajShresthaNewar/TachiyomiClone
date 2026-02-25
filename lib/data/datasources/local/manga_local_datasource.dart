import 'package:sqflite/sqflite.dart';
import 'package:tachiyomiv1/core/error/exceptions.dart';
import 'package:tachiyomiv1/data/datasources/local/database_helper.dart';
import 'package:tachiyomiv1/data/models/manga_model.dart';

abstract class MangaLocalDataSource {
  Future<List<MangaModel>> getCachedManga();
  Future<List<MangaModel>> getFavoriteManga();
  Future<MangaModel?> getMangaById(String id);
  Future<void> cacheManga(List<MangaModel> manga);
  Future<void> toggleFavorite(String mangaId);
  Future<void> clearCache();
}

class MangaLocalDataSourceImpl implements MangaLocalDataSource {
  final DatabaseHelper databaseHelper;

  MangaLocalDataSourceImpl({required this.databaseHelper});

  @override
  Future<List<MangaModel>> getCachedManga() async {
    try {
      final db = await databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'manga',
        orderBy: 'createdAt DESC',
        limit: 50,
      );

      return List.generate(maps.length, (i) {
        return MangaModel.fromDatabase(maps[i]);
      });
    } catch (e) {
      throw CacheException('Failed to get cached manga: $e');
    }
  }

  @override
  Future<List<MangaModel>> getFavoriteManga() async {
    try {
      final db = await databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'manga',
        where: 'isFavorite = ?',
        whereArgs: [1],
        orderBy: 'lastReadAt DESC',
      );

      return List.generate(maps.length, (i) {
        return MangaModel.fromDatabase(maps[i]);
      });
    } catch (e) {
      throw CacheException('Failed to get favorite manga: $e');
    }
  }

  @override
  Future<MangaModel?> getMangaById(String id) async {
    try {
      final db = await databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'manga',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isEmpty) return null;
      return MangaModel.fromDatabase(maps.first);
    } catch (e) {
      throw CacheException('Failed to get manga by id: $e');
    }
  }

  @override
  Future<void> cacheManga(List<MangaModel> mangaList) async {
    try {
      final db = await databaseHelper.database;
      final batch = db.batch();

      for (var manga in mangaList) {
        final mangaData = manga.toJson();
        mangaData['createdAt'] = DateTime.now().toIso8601String();
        
        batch.insert(
          'manga',
          mangaData,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      await batch.commit(noResult: true);
    } catch (e) {
      throw CacheException('Failed to cache manga: $e');
    }
  }

  @override
  Future<void> toggleFavorite(String mangaId) async {
    try {
      final db = await databaseHelper.database;
      
      // Get current favorite status
      final result = await db.query(
        'manga',
        columns: ['isFavorite'],
        where: 'id = ?',
        whereArgs: [mangaId],
      );

      if (result.isEmpty) return;

      final currentStatus = result.first['isFavorite'] as int;
      final newStatus = currentStatus == 1 ? 0 : 1;

      await db.update(
        'manga',
        {
          'isFavorite': newStatus,
          'lastReadAt': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [mangaId],
      );
    } catch (e) {
      throw CacheException('Failed to toggle favorite: $e');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      final db = await databaseHelper.database;
      await db.delete('manga', where: 'isFavorite = ?', whereArgs: [0]);
    } catch (e) {
      throw CacheException('Failed to clear cache: $e');
    }
  }
}