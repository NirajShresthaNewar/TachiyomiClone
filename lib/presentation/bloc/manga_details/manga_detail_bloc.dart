import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tachiyomiv1/domain/usecases/get_manga_chapters.dart';
import 'package:tachiyomiv1/domain/usecases/get_manga_details.dart';
import 'package:tachiyomiv1/domain/usecases/toggle_favorite.dart';
import 'package:tachiyomiv1/presentation/bloc/manga_details/manga_detail_event.dart';
import 'package:tachiyomiv1/presentation/bloc/manga_details/manga_details_state.dart';

class MangaDetailBloc extends Bloc<MangaDetailEvent, MangaDetailState> {
  final GetMangaDetails getMangaDetails;
  final GetMangaChapters getMangaChapters;
  final ToggleFavorite toggleFavorite;

  MangaDetailBloc({
    required this.getMangaDetails,
    required this.getMangaChapters,
    required this.toggleFavorite,
  }) : super(MangaDetailInitial()) {
    on<LoadMangaDetail>(_onLoadMangaDetail);
    on<LoadMangaChapters>(_onLoadMangaChapters);
    on<ToggleFavoriteEvent>(_onToggleFavorite);
  }

  Future<void> _onLoadMangaDetail(
    LoadMangaDetail event,
    Emitter<MangaDetailState> emit,
  ) async {
    emit(MangaDetailLoading());

    final result = await getMangaDetails(
      MangaDetailsParams(mangaId: event.mangaId),
    );

    result.fold(
      (failure) => emit(MangaDetailError(failure.message)),
      (manga) {
        emit(MangaDetailLoaded(manga: manga));
        add(LoadMangaChapters(event.mangaId));
      },
    );
  }

  Future<void> _onLoadMangaChapters(
    LoadMangaChapters event,
    Emitter<MangaDetailState> emit,
  ) async {
    if (state is MangaDetailLoaded) {
      final currentState = state as MangaDetailLoaded;
      emit(currentState.copyWith(isLoadingChapters: true));

      final result = await getMangaChapters(
        ChaptersParams(mangaId: event.mangaId),
      );

      result.fold(
        (failure) => emit(currentState.copyWith(isLoadingChapters: false)),
        (chapters) => emit(currentState.copyWith(
          chapters: chapters,
          isLoadingChapters: false,
        )),
      );
    }
  }

  Future<void> _onToggleFavorite(
    ToggleFavoriteEvent event,
    Emitter<MangaDetailState> emit,
  ) async {
    await toggleFavorite(ToggleFavoriteParams(mangaId: event.mangaId));
  }
}