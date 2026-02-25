import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tachiyomiv1/core/dependency_injection.dart';
import 'package:tachiyomiv1/presentation/bloc/library/library_bloc.dart';
import 'package:tachiyomiv1/presentation/bloc/library/library_event.dart';
import 'package:tachiyomiv1/presentation/bloc/library/library_state.dart';
import 'package:tachiyomiv1/presentation/pages/home/widgets/manga_grid.dart';
import 'package:tachiyomiv1/presentation/widgets/loading_indicator.dart';
import 'package:tachiyomiv1/presentation/widgets/error_message.dart';
import 'package:tachiyomiv1/presentation/widgets/empty_state.dart';

class LibraryPage extends StatelessWidget {
  const LibraryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<LibraryBloc>()..add(LoadLibrary()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Library'),
        ),
        body: BlocBuilder<LibraryBloc, LibraryState>(
          builder: (context, state) {
            if (state is LibraryLoading) {
              return const LoadingIndicator();
            } else if (state is LibraryLoaded) {
              if (state.mangaList.isEmpty) {
                return const EmptyState(
                  message: 'Your library is empty',
                  icon: Icons.favorite_border,
                );
              }
              return MangaGrid(
                mangaList: state.mangaList,
                scrollController: ScrollController(),
                hasReachedMax: true,
              );
            } else if (state is LibraryError) {
              return ErrorMessage(
                message: state.message,
                onRetry: () {
                  context.read<LibraryBloc>().add(LoadLibrary());
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
