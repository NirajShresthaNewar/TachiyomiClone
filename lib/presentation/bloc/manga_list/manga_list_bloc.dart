import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tachiyomiv1/domain/usecases/get_popular_manga.dart';
import 'package:tachiyomiv1/domain/usecases/search_manga.dart';
import 'package:tachiyomiv1/presentation/bloc/manga_list/manga_list_event.dart';
import 'package:tachiyomiv1/presentation/bloc/manga_list/manga_list_state.dart';

class MangaListBloc extends Bloc<MangaListEvent, MangaListState> {
  final GetPopularManga getPopularManga;
  final SearchManga searchManga;

  int _currentOffset = 0;
  static const int _pageSize = 20;

  MangaListBloc({
    required this.getPopularManga,
    required this.searchManga,
  }) : super(MangaListInitial()) {
    on<LoadPopularManga>(_onLoadPopularManga);
    on<LoadMoreManga>(_onLoadMoreManga);
    on<SearchMangaEvent>(_onSearchManga);
    on<ClearSearch>(_onClearSearch);
  }

  Future<void> _onLoadPopularManga(
    LoadPopularManga event,
    Emitter<MangaListState> emit,
  ) async {
    if (event.refresh) {
      _currentOffset = 0;
    }

    emit(MangaListLoading());

    final result = await getPopularManga(
      PopularMangaParams(offset: _currentOffset),
    );

    result.fold(
      (failure) => emit(MangaListError(_mapFailureToMessage(failure))),
      (mangaList) {
        _currentOffset += _pageSize;
        emit(MangaListLoaded(
          mangaList: mangaList,
          hasReachedMax: mangaList.length < _pageSize,
        ));
      },
    );
  }

  Future<void> _onLoadMoreManga(
    LoadMoreManga event,
    Emitter<MangaListState> emit,
  ) async {
    if (state is MangaListLoaded) {
      final currentState = state as MangaListLoaded;

      if (currentState.hasReachedMax || currentState.isSearching) return;

      emit(MangaListLoadingMore(currentState.mangaList));

      final result = await getPopularManga(
        PopularMangaParams(offset: _currentOffset),
      );

      result.fold(
        (failure) => emit(MangaListError(_mapFailureToMessage(failure))),
        (newManga) {
          _currentOffset += _pageSize;
          emit(MangaListLoaded(
            mangaList: [...currentState.mangaList, ...newManga],
            hasReachedMax: newManga.length < _pageSize,
          ));
        },
      );
    }
  }

  Future<void> _onSearchManga(
    SearchMangaEvent event,
    Emitter<MangaListState> emit,
  ) async {
    if (event.query.isEmpty) {
      add(const LoadPopularManga(refresh: true));
      return;
    }

    emit(MangaListLoading());

    final result = await searchManga(SearchMangaParams(query: event.query));

    result.fold(
      (failure) => emit(MangaListError(_mapFailureToMessage(failure))),
      (mangaList) => emit(MangaListLoaded(
        mangaList: mangaList,
        hasReachedMax: true,
        isSearching: true,
      )),
    );
  }

  Future<void> _onClearSearch(
    ClearSearch event,
    Emitter<MangaListState> emit,
  ) async {
    add(const LoadPopularManga(refresh: true));
  }

  String _mapFailureToMessage(failure) {
    return failure.message;
  }
}