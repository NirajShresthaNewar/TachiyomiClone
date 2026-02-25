import 'package:dio/dio.dart';
import 'package:tachiyomiv1/config/constants.dart';
import 'package:tachiyomiv1/core/error/exceptions.dart';
import 'package:tachiyomiv1/core/network/dio_client.dart';
import 'package:tachiyomiv1/data/models/manga_model.dart';
import 'package:tachiyomiv1/data/models/chapter_model.dart';

abstract class MangaRemoteDataSource {
  Future<List<MangaModel>> getPopularManga({int offset = 0, int limit = 20});
  Future<List<MangaModel>> searchManga(String query, {int offset = 0});
  Future<MangaModel> getMangaById(String id);
  Future<List<ChapterModel>> getMangaChapters(String mangaId, {String language = 'en'});
  Future<List<String>> getChapterPages(String chapterId);
}

class MangaRemoteDataSourceImpl implements MangaRemoteDataSource {
  final DioClient dioClient;

  MangaRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<List<MangaModel>> getPopularManga({int offset = 0, int limit = 20}) async {
    try {
      final response = await dioClient.dio.get(
        '/manga',
        queryParameters: {
          'limit': limit,
          'offset': offset,
          'includes[]': ['cover_art', 'author', 'artist'],
          'order[followedCount]': 'desc',
          'contentRating[]': ['safe', 'suggestive'],
        },
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data.map((json) => MangaModel.fromJson(json)).toList();
      } else {
        throw ServerException('Failed to fetch popular manga');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Connection timeout');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('No internet connection');
      } else {
        throw ServerException('Server error: ${e.message}');
      }
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<List<MangaModel>> searchManga(String query, {int offset = 0}) async {
    try {
      final response = await dioClient.dio.get(
        '/manga',
        queryParameters: {
          'title': query,
          'limit': 20,
          'offset': offset,
          'includes[]': ['cover_art', 'author', 'artist'],
          'contentRating[]': ['safe', 'suggestive'],
        },
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data.map((json) => MangaModel.fromJson(json)).toList();
      } else {
        throw ServerException('Failed to search manga');
      }
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  @override
  Future<MangaModel> getMangaById(String id) async {
    try {
      final response = await dioClient.dio.get(
        '/manga/$id',
        queryParameters: {
          'includes[]': ['cover_art', 'author', 'artist'],
        },
      );

      if (response.statusCode == 200) {
        return MangaModel.fromJson(response.data['data']);
      } else {
        throw ServerException('Failed to fetch manga details');
      }
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  @override
  Future<List<ChapterModel>> getMangaChapters(
    String mangaId, {
    String language = 'en',
  }) async {
    try {
      final response = await dioClient.dio.get(
        '/manga/$mangaId/feed',
        queryParameters: {
          'translatedLanguage[]': [language, 'ja', 'pt-br', 'es'], // Added common languages as fallback
          'limit': 500, // Increased limit from 100 to 500 to show more chapters
          'offset': 0,
          'order[chapter]': 'desc',
          'includes[]': ['scanlation_group'],
          'contentRating[]': ['safe', 'suggestive', 'erotica'], // Include more content ratings
        },
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data.map((json) => ChapterModel.fromJson(json)).toList();
      } else {
        throw ServerException('Failed to fetch chapters');
      }
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  @override
  Future<List<String>> getChapterPages(String chapterId) async {
    try {
      final response = await dioClient.dio.get('/at-home/server/$chapterId');

      if (response.statusCode == 200) {
        final String baseUrl = response.data['baseUrl'];
        final Map<String, dynamic> chapter = response.data['chapter'];
        final String hash = chapter['hash'];
        
        // Try dataSaver first, but fall back to data if it's missing or empty
        List<dynamic> pagesData = chapter['dataSaver'] ?? [];
        String type = 'data-saver';

        if (pagesData.isEmpty) {
          pagesData = chapter['data'] ?? [];
          type = 'data';
        }

        if (pagesData.isEmpty) {
          return [];
        }

        // Construct full URLs for each page
        return pagesData.map((filename) {
          // Ensure baseUrl is properly formatted
          final cleanBaseUrl = baseUrl.endsWith('/')
              ? baseUrl.substring(0, baseUrl.length - 1)
              : baseUrl;
          return '$cleanBaseUrl/$type/$hash/$filename';
        }).toList();
      } else {
        throw ServerException('Failed to fetch chapter pages');
      }
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  void _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      throw NetworkException('Connection timeout');
    } else if (e.type == DioExceptionType.connectionError) {
      throw NetworkException('No internet connection');
    } else {
      throw ServerException('Server error: ${e.message}');
    }
  }
}