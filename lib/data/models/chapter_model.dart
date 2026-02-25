import 'package:tachiyomiv1/domain/entities/chapter.dart';

class ChapterModel extends Chapter {
  const ChapterModel({
    required String id,
    required String mangaId,
    required String title,
    String? chapterNumber,
    String? volume,
    required int pageCount,
    required DateTime publishedAt,
    String? language,
    String? externalUrl,
  }) : super(
          id: id,
          mangaId: mangaId,
          title: title,
          chapterNumber: chapterNumber,
          volume: volume,
          pageCount: pageCount,
          publishedAt: publishedAt,
          language: language,
          externalUrl: externalUrl,
        );

  factory ChapterModel.fromJson(Map<String, dynamic> json) {
    final attributes = json['attributes'] as Map<String, dynamic>;
    final relationships = json['relationships'] as List<dynamic>? ?? [];

    // Extract manga ID from relationships
    String? mangaId;
    for (var rel in relationships) {
      if (rel['type'] == 'manga') {
        mangaId = rel['id'] as String?;
        break;
      }
    }

    return ChapterModel(
      id: json['id'] as String,
      mangaId: mangaId ?? '',
      title: attributes['title'] as String? ?? 'Chapter ${attributes['chapter'] ?? ''}',
      chapterNumber: attributes['chapter'] as String?,
      volume: attributes['volume'] as String?,
      pageCount: attributes['pages'] as int? ?? 0,
      publishedAt: DateTime.parse(attributes['publishAt'] as String),
      language: attributes['translatedLanguage'] as String?,
      externalUrl: attributes['externalUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mangaId': mangaId,
      'title': title,
      'chapterNumber': chapterNumber,
      'volume': volume,
      'pageCount': pageCount,
      'publishedAt': publishedAt.toIso8601String(),
      'language': language,
      'externalUrl': externalUrl,
    };
  }
  
  factory ChapterModel.fromDatabase(Map<String, dynamic> map) {
    return ChapterModel(
      id: map['id'] as String,
      mangaId: map['mangaId'] as String,
      title: map['title'] as String,
      chapterNumber: map['chapterNumber'] as String?,
      volume: map['volume'] as String?,
      pageCount: map['pageCount'] as int,
      publishedAt: DateTime.parse(map['publishedAt'] as String),
      language: map['language'] as String?,
      externalUrl: map['externalUrl'] as String?,
    );
  }
}