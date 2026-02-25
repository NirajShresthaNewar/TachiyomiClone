import 'package:dartz/dartz.dart';
import 'package:tachiyomiv1/core/error/failures.dart';
import 'package:tachiyomiv1/domain/entities/manga.dart';
import 'package:tachiyomiv1/data/models/chapter_model.dart';
import 'package:tachiyomiv1/domain/entities/chapter.dart';



abstract class MangaRepository {
  Future<Either<Failure, List<Manga>>> getPopularManga({int offset = 0});
  Future<Either<Failure, List<Manga>>> searchManga(String query);
  Future<Either<Failure, Manga>> getMangaById(String id);
  Future<Either<Failure, List<Chapter>>> getMangaChapters(String mangaId);
  Future<Either<Failure, List<String>>> getChapterPages(String chapterId);
  Future<Either<Failure, List<Manga>>> getFavoriteManga();
  Future<Either<Failure, void>> toggleFavorite(String mangaId);
}