import 'package:equatable/equatable.dart';
import 'package:tachiyomiv1/domain/entities/manga.dart';

abstract class LibraryState extends Equatable {
  const LibraryState();

  @override
  List<Object> get props => [];
}

class LibraryInitial extends LibraryState {}

class LibraryLoading extends LibraryState {}

class LibraryLoaded extends LibraryState {
  final List<Manga> mangaList;

  const LibraryLoaded({required this.mangaList});

  @override
  List<Object> get props => [mangaList];
}

class LibraryError extends LibraryState {
  final String message;

  const LibraryError(this.message);

  @override
  List<Object> get props => [message];
}
