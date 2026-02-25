import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:tachiyomiv1/core/error/failures.dart';
import 'package:tachiyomiv1/core/usecase/usecase.dart';
import 'package:tachiyomiv1/domain/entities/manga.dart';
import 'package:tachiyomiv1/domain/repositories/manga_repository.dart';

class GetPopularManga implements UseCase<List<Manga>, PopularMangaParams> {
  final MangaRepository repository;

  GetPopularManga(this.repository);

  @override
  Future<Either<Failure, List<Manga>>> call(PopularMangaParams params) async {
    return await repository.getPopularManga(offset: params.offset);
  }
}

class PopularMangaParams extends Equatable {
  final int offset;

  const PopularMangaParams({this.offset = 0});

  @override
  List<Object> get props => [offset];
}