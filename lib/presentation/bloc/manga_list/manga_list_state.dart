import 'package:equatable/equatable.dart';
import 'package:tachiyomiv1/domain/entities/manga.dart';

abstract class MangaListState extends Equatable {
  const MangaListState();

  @override
  List<Object> get props => [];
}

class MangaListInitial extends MangaListState {}

class MangaListLoading extends MangaListState {}

class MangaListLoaded extends MangaListState {
  final List<Manga> mangaList;
  final bool hasReachedMax;
  final bool isSearching;

  const MangaListLoaded({
    required this.mangaList,
    this.hasReachedMax = false,
    this.isSearching = false,
  });

  MangaListLoaded copyWith({
    List<Manga>? mangaList,
    bool? hasReachedMax,
    bool? isSearching,
  }) {
    return MangaListLoaded(
      mangaList: mangaList ?? this.mangaList,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isSearching: isSearching ?? this.isSearching,
    );
  }

  @override
  List<Object> get props => [mangaList, hasReachedMax, isSearching];
}

class MangaListLoadingMore extends MangaListState {
  final List<Manga> currentMangaList;

  const MangaListLoadingMore(this.currentMangaList);

  @override
  List<Object> get props => [currentMangaList];
}

class MangaListError extends MangaListState {
  final String message;

  const MangaListError(this.message);

  @override
  List<Object> get props => [message];
}