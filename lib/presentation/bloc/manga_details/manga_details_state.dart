import 'package:equatable/equatable.dart';
import 'package:tachiyomiv1/domain/entities/chapter.dart';
import 'package:tachiyomiv1/domain/entities/manga.dart';

abstract class MangaDetailState extends Equatable {
  const MangaDetailState();

  @override
  List<Object?> get props => [];
}

class MangaDetailInitial extends MangaDetailState {}

class MangaDetailLoading extends MangaDetailState {}

class MangaDetailLoaded extends MangaDetailState {
  final Manga manga;
  final List<Chapter>? chapters;
  final bool isLoadingChapters;

  const MangaDetailLoaded({
    required this.manga,
    this.chapters,
    this.isLoadingChapters = false,
  });

  MangaDetailLoaded copyWith({
    Manga? manga,
    List<Chapter>? chapters,
    bool? isLoadingChapters,
  }) {
    return MangaDetailLoaded(
      manga: manga ?? this.manga,
      chapters: chapters ?? this.chapters,
      isLoadingChapters: isLoadingChapters ?? this.isLoadingChapters,
    );
  }

  @override
  List<Object?> get props => [manga, chapters, isLoadingChapters];
}

class MangaDetailError extends MangaDetailState {
  final String message;

  const MangaDetailError(this.message);

  @override
  List<Object> get props => [message];
}