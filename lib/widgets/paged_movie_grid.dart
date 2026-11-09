import 'package:flutter/material.dart';

import '../models/movie.dart';
import '../services/tmdb_service.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';
import '../utils/navigation.dart';
import 'empty_view.dart';
import 'error_view.dart';
import 'loading_view.dart';
import 'movie_card.dart';

/// Loads one page of movies at a time. Pass any function that fetches a page
/// (trending, popular, search...) and this widget handles the rest:
/// loading spinner, error + retry, empty state and infinite scrolling.
typedef MoviePageFetcher = Future<MoviePage> Function(int page);

class PagedMovieGrid extends StatefulWidget {
  const PagedMovieGrid({
    super.key,
    required this.fetchPage,
    required this.emptyIcon,
    required this.emptyTitle,
    required this.emptyMessage,
  });

  final MoviePageFetcher fetchPage;
  final IconData emptyIcon;
  final String emptyTitle;
  final String emptyMessage;

  @override
  State<PagedMovieGrid> createState() => _PagedMovieGridState();
}

class _PagedMovieGridState extends State<PagedMovieGrid>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _controller = ScrollController();

  List<Movie> _movies = [];
  int _page = 0;
  bool _hasMore = true;
  bool _initialLoading = true;
  bool _loadingMore = false;
  String? _error; // error while loading the first page
  String? _moreError; // error while loading extra pages

  @override
  bool get wantKeepAlive => true; // keeps scroll position when switching tabs

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
    _loadFirstPage();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_controller.hasClients || _moreError != null) return;
    final position = _controller.position;
    if (position.pixels >= position.maxScrollExtent - 400) {
      _loadMore();
    }
  }

  Future<void> _loadFirstPage() async {
    setState(() {
      _initialLoading = true;
      _error = null;
    });
    try {
      final result = await widget.fetchPage(1);
      if (!mounted) return;
      setState(() {
        _movies = List.of(result.movies);
        _page = 1;
        _hasMore = result.hasMore;
        _initialLoading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _initialLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Something unexpected happened. Please try again.';
        _initialLoading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMore || !_hasMore || _initialLoading || _error != null) return;
    setState(() {
      _loadingMore = true;
      _moreError = null;
    });
    try {
      final result = await widget.fetchPage(_page + 1);
      if (!mounted) return;
      setState(() {
        _movies.addAll(result.movies);
        _page = result.page;
        _hasMore = result.hasMore;
        _loadingMore = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _moreError = e.message;
        _loadingMore = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _moreError = 'Could not load more movies.';
        _loadingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // required by AutomaticKeepAliveClientMixin

    if (_initialLoading) return const LoadingView();
    if (_error != null) {
      return ErrorView(message: _error!, onRetry: _loadFirstPage);
    }
    if (_movies.isEmpty) {
      return EmptyView(
        icon: widget.emptyIcon,
        title: widget.emptyTitle,
        message: widget.emptyMessage,
      );
    }

    return CustomScrollView(
      controller: _controller,
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          sliver: SliverGrid(
            gridDelegate: movieGridDelegate,
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final movie = _movies[index];
                return MovieCard(
                  movie: movie,
                  onTap: () => openDetails(context, movie),
                );
              },
              childCount: _movies.length,
            ),
          ),
        ),
        SliverToBoxAdapter(child: _buildFooter()),
      ],
    );
  }

  Widget _buildFooter() {
    if (_loadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: AppColors.accent,
            ),
          ),
        ),
      );
    }
    if (_moreError != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Text(
              _moreError!,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            TextButton.icon(
              onPressed: () {
                setState(() => _moreError = null);
                _loadMore();
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: TextButton.styleFrom(foregroundColor: AppColors.accent),
            ),
          ],
        ),
      );
    }
    if (!_hasMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            "You've reached the end",
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }
    return const SizedBox(height: 24);
  }
}
