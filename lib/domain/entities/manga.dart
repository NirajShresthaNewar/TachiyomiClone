import 'package:equatable/equatable.dart';

class Manga extends Equatable {
  final String id;
  final String title;
  final String? description;
  final String? coverUrl;
  final List<String> authors;
  final List<String> genres;
  final double rating;
  final int chapterCount;
  final String status; // ongoing, completed, etc

  const Manga({
    required this.id,
    required this.title,
    this.description,
    this.coverUrl,
    required this.authors,
    required this.genres,
    required this.rating,
    required this.chapterCount,
    required this.status,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    coverUrl,
    authors,
    genres,
    rating,
    chapterCount,
    status,
  ];
}