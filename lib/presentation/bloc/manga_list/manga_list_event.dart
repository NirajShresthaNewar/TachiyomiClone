import 'package:equatable/equatable.dart';

abstract class MangaListEvent extends Equatable {
  const MangaListEvent();

  @override
  List<Object> get props => [];
}

class LoadPopularManga extends MangaListEvent {
  final bool refresh;

  const LoadPopularManga({this.refresh = false});

  @override
  List<Object> get props => [refresh];
}

class LoadMoreManga extends MangaListEvent {}

class SearchMangaEvent extends MangaListEvent {
  final String query;

  const SearchMangaEvent(this.query);

  @override
  List<Object> get props => [query];
}

class ClearSearch extends MangaListEvent {}