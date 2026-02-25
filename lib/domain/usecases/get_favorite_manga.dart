import 'package:dartz/dartz.dart';
import 'package:tachiyomiv1/core/error/failures.dart';
import 'package:tachiyomiv1/core/usecase/usecase.dart';
import 'package:tachiyomiv1/domain/entities/manga.dart';
import 'package:tachiyomiv1/domain/repositories/manga_repository.dart';

class GetFavoriteManga implements UseCase<List<Manga>, NoParams> {
  final MangaRepository repository;

  GetFavoriteManga(this.repository);

  @override
  Future<Either<Failure, List<Manga>>> call(NoParams params) async {
    return await repository.getFavoriteManga();
  }
}