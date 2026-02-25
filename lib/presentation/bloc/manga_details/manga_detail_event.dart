import 'package:equatable/equatable.dart';

abstract class MangaDetailEvent extends Equatable {
  const MangaDetailEvent();

  @override
  List<Object> get props => [];
}

class LoadMangaDetail extends MangaDetailEvent {
  final String mangaId;

  const LoadMangaDetail(this.mangaId);

  @override
  List<Object> get props => [mangaId];
}

class LoadMangaChapters extends MangaDetailEvent {
  final String mangaId;

  const LoadMangaChapters(this.mangaId);

  @override
  List<Object> get props => [mangaId];
}

class ToggleFavoriteEvent extends MangaDetailEvent {
  final String mangaId;

  const ToggleFavoriteEvent(this.mangaId);

  @override
  List<Object> get props => [mangaId];
}