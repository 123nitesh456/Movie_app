import 'package:flutter/material.dart';

import '../services/tmdb_service.dart';
import '../utils/app_theme.dart';
import '../widgets/paged_movie_grid.dart';

/// Home: "Trending" and "Popular" tabs, each with infinite scrolling.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = TmdbService.instance;

    return DefaultTabController(
      length: 2,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Text(
                'Discover',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 2, 20, 8),
              child: Text(
                'Find your next favourite movie',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            const TabBar(
              dividerColor: Colors.transparent,
              indicatorColor: AppColors.accent,
              indicatorSize: TabBarIndicatorSize.label,
              labelColor: AppColors.accent,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              tabs: [
                Tab(text: 'Trending'),
                Tab(text: 'Popular'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  PagedMovieGrid(
                    fetchPage: (page) => service.getTrendingMovies(page: page),
                    emptyIcon: Icons.local_fire_department_outlined,
                    emptyTitle: 'Nothing trending',
                    emptyMessage: 'No trending movies right now. Check back soon.',
                  ),
                  PagedMovieGrid(
                    fetchPage: (page) => service.getPopularMovies(page: page),
                    emptyIcon: Icons.movie_filter_outlined,
                    emptyTitle: 'No popular movies',
                    emptyMessage: 'No popular movies to show right now.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
