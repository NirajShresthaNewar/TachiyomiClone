import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:tachiyomiv1/core/error/failures.dart';
import 'package:tachiyomiv1/core/usecase/usecase.dart';
import 'package:tachiyomiv1/domain/entities/manga.dart';
import 'package:tachiyomiv1/domain/repositories/manga_repository.dart';

class SearchManga implements UseCase<List<Manga>, SearchMangaParams> {
  final MangaRepository repository;

  SearchManga(this.repository);

  @override
  Future<Either<Failure, List<Manga>>> call(SearchMangaParams params) async {
    return await repository.searchManga(params.query);
  }
}

class SearchMangaParams extends Equatable {
  final String query;

  const SearchMangaParams({required this.query});

  @override
  List<Object> get props => [query];
}