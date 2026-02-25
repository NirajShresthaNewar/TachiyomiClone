import 'package:dartz/dartz.dart';
import 'package:tachiyomiv1/core/error/exceptions.dart';
import 'package:tachiyomiv1/core/error/failures.dart';
import 'package:tachiyomiv1/data/datasources/local/manga_local_datasource.dart';
import 'package:tachiyomiv1/data/datasources/remote/manga_remote_datasource.dart';
import 'package:tachiyomiv1/data/models/chapter_model.dart';
import 'package:tachiyomiv1/domain/entities/manga.dart';
import 'package:tachiyomiv1/domain/repositories/manga_repository.dart';
import 'package:tachiyomiv1/domain/entities/chapter.dart';

class MangaRepositoryImpl implements MangaRepository {
  final MangaRemoteDataSource remoteDataSource;
  final MangaLocalDataSource localDataSource;

  MangaRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<Manga>>> getPopularManga({int offset = 0}) async {
    try {
      final remoteManga = await remoteDataSource.getPopularManga(offset: offset);
      try {
        await localDataSource.cacheManga(remoteManga);
      } catch (e) {
        // Don't fail the request if caching fails (e.g., on Web)
        print('Caching failed: $e');
      }
      return Right(remoteManga);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      // Try to return cached data if network fails
      try {
        final cachedManga = await localDataSource.getCachedManga();
        if (cachedManga.isNotEmpty) {
          return Right(cachedManga);
        }
      } catch (_) {}
      return Left(NetworkFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Manga>>> searchManga(String query) async {
    try {
      final results = await remoteDataSource.searchManga(query);
      return Right(results);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Manga>> getMangaById(String id) async {
    try {
      // Try cache first
      try {
        final cachedManga = await localDataSource.getMangaById(id);
        if (cachedManga != null) {
          return Right(cachedManga);
        }
      } catch (e) {
        print('Cache read failed: $e');
      }

      // Fetch from remote
      final manga = await remoteDataSource.getMangaById(id);
      try {
        await localDataSource.cacheManga([manga]);
      } catch (e) {
        print('Cache write failed: $e');
      }
      return Right(manga);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Chapter>>> getMangaChapters(String mangaId) async {
    try {
      final chapters = await remoteDataSource.getMangaChapters(mangaId);
      return Right(chapters);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getChapterPages(String chapterId) async {
    try {
      final pages = await remoteDataSource.getChapterPages(chapterId);
      return Right(pages);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Manga>>> getFavoriteManga() async {
    try {
      final favorites = await localDataSource.getFavoriteManga();
      return Right(favorites);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> toggleFavorite(String mangaId) async {
    try {
      await localDataSource.toggleFavorite(mangaId);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }
}