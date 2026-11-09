import 'dart:async';

import 'package:flutter/material.dart';

import '../services/tmdb_service.dart';
import '../utils/app_theme.dart';
import '../widgets/empty_view.dart';
import '../widgets/paged_movie_grid.dart';

/// Search by title. Waits 450 ms after typing stops so we don't call the API
/// on every keystroke.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _textController = TextEditingController();
  Timer? _debounce;
  String _query = '';

  @override
  void dispose() {
    _debounce?.cancel();
    _textController.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    setState(() {}); // refreshes the clear (X) button
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), () {
      _applyQuery(value);
    });
  }

  void _applyQuery(String value) {
    final trimmed = value.trim();
    if (trimmed == _query || !mounted) return;
    setState(() => _query = trimmed);
  }

  void _clear() {
    _debounce?.cancel();
    _textController.clear();
    setState(() => _query = '');
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Text(
              'Search',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _textController,
              onChanged: _onChanged,
              onSubmitted: (value) {
                _debounce?.cancel();
                _applyQuery(value);
              },
              textInputAction: TextInputAction.search,
              cursorColor: AppColors.accent,
              decoration: InputDecoration(
                hintText: 'Search movies by title',
                hintStyle: const TextStyle(color: AppColors.textSecondary),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.textSecondary,
                ),
                suffixIcon: _textController.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close_rounded),
                        color: AppColors.textSecondary,
                        onPressed: _clear,
                      ),
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.accent),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _query.isEmpty
                ? const EmptyView(
                    icon: Icons.search_rounded,
                    title: 'Search for a movie',
                    message: 'Type a movie title above to see results.',
                  )
                : PagedMovieGrid(
                    // A new key restarts the grid for every new search.
                    key: ValueKey(_query),
                    fetchPage: (page) =>
                        TmdbService.instance.searchMovies(_query, page: page),
                    emptyIcon: Icons.search_off_rounded,
                    emptyTitle: 'No movies found',
                    emptyMessage:
                        'We couldn\'t find anything for "$_query". Try a different title.',
                  ),
          ),
        ],
      ),
    );
  }
}
