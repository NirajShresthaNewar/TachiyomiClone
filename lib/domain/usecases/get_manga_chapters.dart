import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:tachiyomiv1/core/error/failures.dart';
import 'package:tachiyomiv1/core/usecase/usecase.dart';
import 'package:tachiyomiv1/data/models/chapter_model.dart';
import 'package:tachiyomiv1/domain/entities/chapter.dart';
import 'package:tachiyomiv1/domain/repositories/manga_repository.dart';

class GetMangaChapters implements UseCase<List<Chapter>, ChaptersParams> {
  final MangaRepository repository;

  GetMangaChapters(this.repository);

  @override
  Future<Either<Failure, List<Chapter>>> call(ChaptersParams params) async {
    return await repository.getMangaChapters(params.mangaId);
  }
}

class ChaptersParams extends Equatable {
  final String mangaId;

  const ChaptersParams({required this.mangaId});

  @override
  List<Object> get props => [mangaId];
}