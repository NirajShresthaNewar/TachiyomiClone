import 'package:get_it/get_it.dart';
import 'package:tachiyomiv1/core/network/dio_client.dart';
import 'package:tachiyomiv1/data/datasources/local/database_helper.dart';
import 'package:tachiyomiv1/data/datasources/local/manga_local_datasource.dart';
import 'package:tachiyomiv1/data/datasources/remote/manga_remote_datasource.dart';
import 'package:tachiyomiv1/data/repositories/manga_repository_impl.dart';
import 'package:tachiyomiv1/domain/repositories/manga_repository.dart';
import 'package:tachiyomiv1/domain/usecases/get_chapter_pages.dart';
import 'package:tachiyomiv1/domain/usecases/get_favorite_manga.dart';
import 'package:tachiyomiv1/domain/usecases/get_manga_chapters.dart';
import 'package:tachiyomiv1/domain/usecases/get_manga_details.dart';
import 'package:tachiyomiv1/domain/usecases/get_popular_manga.dart';
import 'package:tachiyomiv1/domain/usecases/search_manga.dart';
import 'package:tachiyomiv1/domain/usecases/toggle_favorite.dart';
import 'package:tachiyomiv1/presentation/bloc/library/library_bloc.dart';
import 'package:tachiyomiv1/presentation/bloc/manga_details/manga_detail_bloc.dart';
import 'package:tachiyomiv1/presentation/bloc/manga_list/manga_list_bloc.dart';
import 'package:tachiyomiv1/presentation/bloc/reader/reader_bloc.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  // Core
  getIt.registerSingleton<DioClient>(DioClient());
  getIt.registerSingleton<DatabaseHelper>(DatabaseHelper.instance);

  // Data sources
  getIt.registerLazySingleton<MangaRemoteDataSource>(
    () => MangaRemoteDataSourceImpl(dioClient: getIt()),
  );

  getIt.registerLazySingleton<MangaLocalDataSource>(
    () => MangaLocalDataSourceImpl(databaseHelper: getIt()),
  );

  // Repository
  getIt.registerLazySingleton<MangaRepository>(
    () => MangaRepositoryImpl(
      remoteDataSource: getIt(),
      localDataSource: getIt(),
    ),
  );

  // Use cases
  getIt.registerLazySingleton(() => GetPopularManga(getIt()));
  getIt.registerLazySingleton(() => SearchManga(getIt()));
  getIt.registerLazySingleton(() => GetMangaDetails(getIt()));
  getIt.registerLazySingleton(() => GetMangaChapters(getIt()));
  getIt.registerLazySingleton(() => GetChapterPages(getIt()));
  getIt.registerLazySingleton(() => GetFavoriteManga(getIt()));
  getIt.registerLazySingleton(() => ToggleFavorite(getIt()));

  // BLoCs
  getIt.registerFactory(
    () => MangaListBloc(
      getPopularManga: getIt(),
      searchManga: getIt(),
    ),
  );

  getIt.registerFactory(
    () => MangaDetailBloc(
      getMangaDetails: getIt(),
      getMangaChapters: getIt(),
      toggleFavorite: getIt(),
    ),
  );

  getIt.registerFactory(
    () => LibraryBloc(
      getFavoriteManga: getIt(),
    ),
  );

  getIt.registerFactory(
    () => ReaderBloc(
      getChapterPages: getIt(),
    ),
  );
  // Use cases will be added in Phase 3
}