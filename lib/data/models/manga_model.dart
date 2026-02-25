import 'package:tachiyomiv1/domain/entities/manga.dart';

class MangaModel extends Manga {
  const MangaModel({
    required String id,
    required String title,
    String? description,
    String? coverUrl,
    required List<String> authors,
    required List<String> genres,
    required double rating,
    required int chapterCount,
    required String status,
  }) : super(
          id: id,
          title: title,
          description: description,
          coverUrl: coverUrl,
          authors: authors,
          genres: genres,
          rating: rating,
          chapterCount: chapterCount,
          status: status,
        );

  // From JSON (MangaDex API response)
  factory MangaModel.fromJson(Map<String, dynamic> json) {
    final attributes = json['attributes'] as Map<String, dynamic>;
    final relationships = json['relationships'] as List<dynamic>? ?? [];

    // Extract title (MangaDex has multiple language titles)
    final titleMap = attributes['title'] as Map<String, dynamic>? ?? {};
    final title = titleMap['en'] ?? titleMap.values.first ?? 'Unknown Title';

    // Extract description
    final descriptionMap = attributes['description'] as Map<String, dynamic>? ?? {};
    final description = descriptionMap['en'] ?? descriptionMap.values.firstOrNull;

    // Extract authors
    final authors = relationships
        .where((rel) => rel['type'] == 'author' || rel['type'] == 'artist')
        .map((rel) => rel['attributes']?['name'] as String? ?? 'Unknown')
        .toList();

    // Extract genres/tags
    final tags = attributes['tags'] as List<dynamic>? ?? [];
    final genres = tags
        .map((tag) {
          final tagAttributes = tag['attributes'] as Map<String, dynamic>?;
          final nameMap = tagAttributes?['name'] as Map<String, dynamic>? ?? {};
          return nameMap['en'] as String? ?? '';
        })
        .where((name) => name.isNotEmpty)
        .toList();

    // Extract cover fileName from relationships
    String? fileName;
    for (var rel in relationships) {
      if (rel['type'] == 'cover_art') {
        final relAttributes = rel['attributes'] as Map<String, dynamic>?;
        fileName = relAttributes?['fileName'] as String?;
        break;
      }
    }

    // Build cover URL
    String? coverUrl;
    if (fileName != null) {
      coverUrl = 'https://uploads.mangadex.org/covers/${json['id']}/$fileName.256.jpg';
    }

    return MangaModel(
      id: json['id'] as String,
      title: title,
      description: description,
      coverUrl: coverUrl,
      authors: authors,
      genres: genres,
      rating: 0.0, // MangaDex doesn't provide ratings in basic search
      chapterCount: 0, // Need separate API call for chapter count
      status: attributes['status'] as String? ?? 'unknown',
    );
  }

  // To JSON (for local database)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'coverUrl': coverUrl,
      'authors': authors.join(','),
      'genres': genres.join(','),
      'rating': rating,
      'chapterCount': chapterCount,
      'status': status,
    };
  }

  // From database
  factory MangaModel.fromDatabase(Map<String, dynamic> map) {
    return MangaModel(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      coverUrl: map['coverUrl'] as String?,
      authors: (map['authors'] as String).split(','),
      genres: (map['genres'] as String).split(','),
      rating: map['rating'] as double,
      chapterCount: map['chapterCount'] as int,
      status: map['status'] as String,
    );
  }
}