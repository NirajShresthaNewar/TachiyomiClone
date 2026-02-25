import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tachiyomiv1/core/dependency_injection.dart';
import 'package:tachiyomiv1/presentation/bloc/reader/reader_bloc.dart';
import 'package:tachiyomiv1/presentation/bloc/reader/reader_event.dart';
import 'package:tachiyomiv1/presentation/bloc/reader/reader_state.dart';
import 'package:tachiyomiv1/presentation/widgets/loading_indicator.dart';
import 'package:tachiyomiv1/presentation/widgets/error_message.dart';
import 'package:tachiyomiv1/presentation/pages/reader/webview_reader_page.dart';

class ReaderPage extends StatefulWidget {
  final String chapterId;
  final String chapterTitle;
  final String? externalUrl;

  const ReaderPage({
    super.key,
    required this.chapterId,
    required this.chapterTitle,
    this.externalUrl,
  });

  @override
  State<ReaderPage> createState() => _ReaderPageState();
}

class _ReaderPageState extends State<ReaderPage> {
  final ScrollController _scrollController = ScrollController();
  bool _showAppBar = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    // Optional: Hide appbar on scroll down, show on scroll up
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ReaderBloc>()..add(LoadChapterPages(widget.chapterId)),
      child: Scaffold(
        backgroundColor: Colors.black,
        extendBodyBehindAppBar: true,
        appBar: _showAppBar
            ? AppBar(
                backgroundColor: Colors.black.withOpacity(0.7),
                foregroundColor: Colors.white,
                elevation: 0,
                title: Text(
                  widget.chapterTitle,
                  style: const TextStyle(fontSize: 16),
                ),
              )
            : null,
        body: BlocBuilder<ReaderBloc, ReaderState>(
          builder: (context, state) {
            if (state is ReaderLoading) {
              return const LoadingIndicator();
            } else if (state is ReaderLoaded) {
              if (state.pages.isEmpty) {
                return const ErrorMessage(
                  message: 'No pages found for this chapter.',
                );
              }
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _showAppBar = !_showAppBar;
                  });
                },
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: state.pages.length,
                  cacheExtent: 2000, // Preload images for smoother scrolling
                  itemBuilder: (context, index) {
                    final imageUrl = state.pages[index];
                    return Column(
                      children: [
                        CachedNetworkImage(
                          imageUrl: imageUrl,
                          width: double.infinity,
                          fit: BoxFit.contain,
                          memCacheWidth: 1080, // Optimize memory usage
                          placeholder: (context, url) => Container(
                            height: 400,
                            color: Colors.black,
                            child: const Center(
                              child: CircularProgressIndicator(color: Colors.white),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            height: 200,
                            color: Colors.grey[900],
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.error, color: Colors.red, size: 40),
                                const SizedBox(height: 8),
                                const Text(
                                  'Failed to load image',
                                  style: TextStyle(color: Colors.white),
                                ),
                                TextButton(
                                  onPressed: () {
                                    PaintingBinding.instance.imageCache.clear();
                                    context.read<ReaderBloc>().add(LoadChapterPages(widget.chapterId));
                                  },
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Small gap between pages like in Tachiyomi's continuous vertical mode
                        Container(height: 1, color: Colors.black),
                      ],
                    );
                  },
                ),
              );
            } else if (state is ReaderError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 60),
                      const SizedBox(height: 16),
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      const SizedBox(height: 24),
                      if (state.message.contains('external link')) ...[
                        ElevatedButton.icon(
                          onPressed: () {
                            final url = widget.externalUrl ?? 'https://mangadex.org/chapter/${widget.chapterId}';
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => WebViewReaderPage(
                                  url: url,
                                  title: widget.chapterTitle,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.chrome_reader_mode),
                          label: const Text('Open in App Reader'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            foregroundColor: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () async {
                            final url = Uri.parse(widget.externalUrl ?? 'https://mangadex.org/chapter/${widget.chapterId}');
                            if (await canLaunchUrl(url)) {
                              await launchUrl(url, mode: LaunchMode.externalApplication);
                            }
                          },
                          icon: const Icon(Icons.open_in_browser),
                          label: const Text('Open in Browser'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      TextButton.icon(
                        onPressed: () {
                          context.read<ReaderBloc>().add(LoadChapterPages(widget.chapterId));
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                        style: TextButton.styleFrom(foregroundColor: Colors.white70),
                      ),
                    ],
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
