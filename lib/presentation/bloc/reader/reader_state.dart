import 'package:equatable/equatable.dart';

abstract class ReaderState extends Equatable {
  const ReaderState();

  @override
  List<Object> get props => [];
}

class ReaderInitial extends ReaderState {}

class ReaderLoading extends ReaderState {}

class ReaderLoaded extends ReaderState {
  final List<String> pages;
  final int currentPage;

  const ReaderLoaded({
    required this.pages,
    this.currentPage = 0,
  });

  ReaderLoaded copyWith({
    List<String>? pages,
    int? currentPage,
  }) {
    return ReaderLoaded(
      pages: pages ?? this.pages,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  List<Object> get props => [pages, currentPage];
}

class ReaderError extends ReaderState {
  final String message;

  const ReaderError(this.message);

  @override
  List<Object> get props => [message];
}