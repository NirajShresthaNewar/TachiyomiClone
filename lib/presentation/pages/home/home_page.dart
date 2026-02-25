import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tachiyomiv1/core/dependency_injection.dart';
import 'package:tachiyomiv1/presentation/bloc/manga_list/manga_list_bloc.dart';
import 'package:tachiyomiv1/presentation/bloc/manga_list/manga_list_event.dart';
import 'package:tachiyomiv1/presentation/bloc/manga_list/manga_list_state.dart';
import 'package:tachiyomiv1/presentation/pages/home/widgets/manga_grid.dart';
import 'package:tachiyomiv1/presentation/pages/home/widgets/search_bar_widget.dart';
import 'package:tachiyomiv1/presentation/pages/library/library_page.dart';
import 'package:tachiyomiv1/presentation/widgets/error_message.dart';
import 'package:tachiyomiv1/presentation/widgets/loading_indicator.dart';
import 'package:tachiyomiv1/presentation/widgets/empty_state.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<MangaListBloc>()..add(const LoadPopularManga()),
      child: const HomePageContent(),
    );
  }
}

class HomePageContent extends StatefulWidget {
  const HomePageContent({super.key});

  @override
  State<HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<MangaListBloc>().add(LoadMoreManga());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  void _onSearch(String query) {
    if (query.isEmpty) {
      context.read<MangaListBloc>().add(ClearSearch());
    } else {
      context.read<MangaListBloc>().add(SearchMangaEvent(query));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manga Reader'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LibraryPage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          SearchBarWidget(
            controller: _searchController,
            onSearch: _onSearch,
            onClear: () {
              _searchController.clear();
              context.read<MangaListBloc>().add(ClearSearch());
            },
          ),
          // Manga Grid
          Expanded(
            child: BlocBuilder<MangaListBloc, MangaListState>(
              builder: (context, state) {
                if (state is MangaListLoading) {
                  return const LoadingIndicator();
                } else if (state is MangaListLoaded) {
                  return MangaGrid(
                    mangaList: state.mangaList,
                    scrollController: _scrollController,
                    hasReachedMax: state.hasReachedMax,
                  );
                } else if (state is MangaListLoadingMore) {
                  return MangaGrid(
                    mangaList: state.currentMangaList,
                    scrollController: _scrollController,
                    isLoadingMore: true,
                    hasReachedMax: false,
                  );
                } else if (state is MangaListError) {
                  return ErrorMessage(
                    message: state.message,
                    onRetry: () {
                      context.read<MangaListBloc>().add(
                            const LoadPopularManga(refresh: true),
                          );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}