import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tachiyomiv1/domain/usecases/get_chapter_pages.dart';
import 'package:tachiyomiv1/presentation/bloc/reader/reader_event.dart';
import 'package:tachiyomiv1/presentation/bloc/reader/reader_state.dart';

class ReaderBloc extends Bloc<ReaderEvent, ReaderState> {
  final GetChapterPages getChapterPages;

  ReaderBloc({required this.getChapterPages}) : super(ReaderInitial()) {
    on<LoadChapterPages>(_onLoadChapterPages);
    on<ChangePageEvent>(_onChangePage);
  }

  Future<void> _onLoadChapterPages(
    LoadChapterPages event,
    Emitter<ReaderState> emit,
  ) async {
    emit(ReaderLoading());

    final result = await getChapterPages(
      ChapterPagesParams(chapterId: event.chapterId),
    );

    result.fold(
      (failure) => emit(ReaderError(failure.message)),
      (pages) {
        if (pages.isEmpty) {
          emit(const ReaderError('No pages found for this chapter. It might be an external link.'));
        } else {
          emit(ReaderLoaded(pages: pages));
        }
      },
    );
  }

  Future<void> _onChangePage(
    ChangePageEvent event,
    Emitter<ReaderState> emit,
  ) async {
    if (state is ReaderLoaded) {
      final currentState = state as ReaderLoaded;
      emit(currentState.copyWith(currentPage: event.pageIndex));
    }
  }
}