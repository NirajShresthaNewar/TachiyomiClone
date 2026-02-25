import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:tachiyomiv1/core/error/failures.dart';
import 'package:tachiyomiv1/core/usecase/usecase.dart';
import 'package:tachiyomiv1/domain/repositories/manga_repository.dart';

class GetChapterPages implements UseCase<List<String>, ChapterPagesParams> {
  final MangaRepository repository;

  GetChapterPages(this.repository);

  @override
  Future<Either<Failure, List<String>>> call(ChapterPagesParams params) async {
    return await repository.getChapterPages(params.chapterId);
  }
}

class ChapterPagesParams extends Equatable {
  final String chapterId;

  const ChapterPagesParams({required this.chapterId});

  @override
  List<Object> get props => [chapterId];
}