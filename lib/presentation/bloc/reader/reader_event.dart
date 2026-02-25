import 'package:equatable/equatable.dart';

abstract class ReaderEvent extends Equatable {
  const ReaderEvent();

  @override
  List<Object> get props => [];
}

class LoadChapterPages extends ReaderEvent {
  final String chapterId;

  const LoadChapterPages(this.chapterId);

  @override
  List<Object> get props => [chapterId];
}

class ChangePageEvent extends ReaderEvent {
  final int pageIndex;

  const ChangePageEvent(this.pageIndex);

  @override
  List<Object> get props => [pageIndex];
}