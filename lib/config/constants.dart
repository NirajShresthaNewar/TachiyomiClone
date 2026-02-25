class ApiConstants {
  static const String mangaDexBaseUrl = 'https://api.mangadex.org';
  static const String mangaDexVersion = '/v5';
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}

class AppConstants {
  static const String appName = 'MangaReader';
  static const String appVersion = '1.0.0';
  static const int pageSize = 20;
}