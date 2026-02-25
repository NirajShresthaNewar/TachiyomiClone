import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tachiyomiv1/core/dependency_injection.dart';
import 'package:tachiyomiv1/presentation/bloc/manga_details/manga_detail_bloc.dart';
import 'package:tachiyomiv1/presentation/bloc/manga_details/manga_detail_event.dart';
import 'package:tachiyomiv1/presentation/bloc/manga_details/manga_details_state.dart';
import 'package:tachiyomiv1/presentation/pages/reader/reader_page.dart';
import 'package:tachiyomiv1/presentation/widgets/loading_indicator.dart';
import 'package:tachiyomiv1/presentation/widgets/error_message.dart';

class MangaDetailPage extends StatelessWidget {
  final String mangaId;

  const MangaDetailPage({Key? key, required this.mangaId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<MangaDetailBloc>()..add(LoadMangaDetail(mangaId)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Manga Details'),
          actions: [
            BlocBuilder<MangaDetailBloc, MangaDetailState>(
              builder: (context, state) {
                return IconButton(
                  icon: const Icon(Icons.favorite_border),
                  onPressed: () {
                    context.read<MangaDetailBloc>().add(ToggleFavoriteEvent(mangaId));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Added to Library')),
                    );
                  },
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<MangaDetailBloc, MangaDetailState>(
          builder: (context, state) {
            if (state is MangaDetailLoading) {
              return const LoadingIndicator();
            } else if (state is MangaDetailLoaded) {
              final manga = state.manga;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (manga.coverUrl != null)
                      Center(
                        child: CachedNetworkImage(
                          imageUrl: manga.coverUrl!,
                          height: 300,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            height: 300,
                            width: 200,
                            color: Colors.grey[300],
                            child: const Center(child: CircularProgressIndicator()),
                          ),
                          errorWidget: (context, url, error) => Container(
                            height: 300,
                            width: 200,
                            color: Colors.grey[300],
                            child: const Icon(Icons.book, size: 50, color: Colors.grey),
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    Text(
                      manga.title,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text('Status: ${manga.status}'),
                    const SizedBox(height: 8),
                    Text('Authors: ${manga.authors.join(', ')}'),
                    const SizedBox(height: 16),
                    Text(
                      'Description',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(manga.description ?? 'No description available'),
                    const SizedBox(height: 16),
                    Text(
                      'Chapters',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (state.isLoadingChapters)
                      const LoadingIndicator()
                    else if (state.chapters != null)
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: state.chapters!.length,
                        itemBuilder: (context, index) {
                          final chapter = state.chapters![index];
                          return ListTile(
                            title: Text(chapter.title),
                            subtitle: Text('Chapter ${chapter.chapterNumber ?? ''}'),
                            trailing: chapter.externalUrl != null
                                ? const Icon(Icons.open_in_new, size: 20)
                                : null,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ReaderPage(
                                    chapterId: chapter.id,
                                    chapterTitle: chapter.title,
                                    externalUrl: chapter.externalUrl,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      )
                    else
                      const Text('No chapters found'),
                  ],
                ),
              );
            } else if (state is MangaDetailError) {
              return ErrorMessage(
                message: state.message,
                onRetry: () {
                  context.read<MangaDetailBloc>().add(LoadMangaDetail(mangaId));
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
