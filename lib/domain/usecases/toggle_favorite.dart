import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:tachiyomiv1/core/error/failures.dart';
import 'package:tachiyomiv1/core/usecase/usecase.dart';
import 'package:tachiyomiv1/domain/repositories/manga_repository.dart';

class ToggleFavorite implements UseCase<void, ToggleFavoriteParams> {
  final MangaRepository repository;

  ToggleFavorite(this.repository);

  @override
  Future<Either<Failure, void>> call(ToggleFavoriteParams params) async {
    return await repository.toggleFavorite(params.mangaId);
  }
}

class ToggleFavoriteParams extends Equatable {
  final String mangaId;

  const ToggleFavoriteParams({required this.mangaId});

  @override
  List<Object> get props => [mangaId];
}