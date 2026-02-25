import 'package:flutter/material.dart';
import 'package:tachiyomiv1/domain/entities/manga.dart';
import 'package:tachiyomiv1/presentation/pages/manga_detail/manga_detail_page.dart';
import 'package:tachiyomiv1/presentation/widgets/empty_state.dart';
import 'package:tachiyomiv1/presentation/widgets/manga_card.dart';

class MangaGrid extends StatelessWidget {
  final List<Manga> mangaList;
  final ScrollController scrollController;
  final bool hasReachedMax;
  final bool isLoadingMore;

  const MangaGrid({
    Key? key,
    required this.mangaList,
    required this.scrollController,
    this.hasReachedMax = false,
    this.isLoadingMore = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (mangaList.isEmpty) {
      return const EmptyState(
        message: 'No manga found',
        icon: Icons.search_off,
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        // Implement pull to refresh
      },
      child: GridView.builder(
        controller: scrollController,
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.65,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: mangaList.length + (isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= mangaList.length) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final manga = mangaList[index];
          return MangaCard(
            manga: manga,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MangaDetailPage(mangaId: manga.id),
                ),
              );
            },
          );
        },
      ),
    );
  }
}