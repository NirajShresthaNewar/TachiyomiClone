import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:tachiyomiv1/core/error/failures.dart';
import 'package:tachiyomiv1/core/usecase/usecase.dart';
import 'package:tachiyomiv1/domain/entities/manga.dart';
import 'package:tachiyomiv1/domain/repositories/manga_repository.dart';

class GetMangaDetails implements UseCase<Manga, MangaDetailsParams> {
  final MangaRepository repository;

  GetMangaDetails(this.repository);

  @override
  Future<Either<Failure, Manga>> call(MangaDetailsParams params) async {
    return await repository.getMangaById(params.mangaId);
  }
}

class MangaDetailsParams extends Equatable {
  final String mangaId;

  const MangaDetailsParams({required this.mangaId});

  @override
  List<Object> get props => [mangaId];
}