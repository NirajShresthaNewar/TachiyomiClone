import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tachiyomiv1/domain/usecases/get_favorite_manga.dart';
import 'package:tachiyomiv1/core/usecase/usecase.dart';
import 'package:tachiyomiv1/presentation/bloc/library/library_event.dart';
import 'package:tachiyomiv1/presentation/bloc/library/library_state.dart';

class LibraryBloc extends Bloc<LibraryEvent, LibraryState> {
  final GetFavoriteManga getFavoriteManga;

  LibraryBloc({required this.getFavoriteManga}) : super(LibraryInitial()) {
    on<LoadLibrary>(_onLoadLibrary);
  }

  Future<void> _onLoadLibrary(
    LoadLibrary event,
    Emitter<LibraryState> emit,
  ) async {
    emit(LibraryLoading());

    final result = await getFavoriteManga(NoParams());

    result.fold(
      (failure) => emit(LibraryError(failure.message)),
      (mangaList) => emit(LibraryLoaded(mangaList: mangaList)),
    );
  }
}
