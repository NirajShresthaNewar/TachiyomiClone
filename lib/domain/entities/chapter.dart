// TODO Implement this library.import 'package:equatable/equatable.dart';

import 'package:equatable/equatable.dart';

class Chapter extends Equatable {
  final String id;
  final String mangaId;
  final String title;
  final String? chapterNumber;
  final String? volume;
  final int pageCount;
  final DateTime publishedAt;
  final String? language;
  final String? externalUrl;

  const Chapter({
    required this.id,
    required this.mangaId,
    required this.title,
    this.chapterNumber,
    this.volume,
    required this.pageCount,
    required this.publishedAt,
    this.language,
    this.externalUrl,
  });

  @override
  List<Object?> get props => [
        id,
        mangaId,
        title,
        chapterNumber,
        volume,
        pageCount,
        publishedAt,
        language,
        externalUrl,
      ];
}