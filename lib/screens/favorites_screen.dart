import 'package:flutter/material.dart';

import '../services/favorites_service.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';
import '../utils/navigation.dart';
import '../widgets/empty_view.dart';
import '../widgets/movie_card.dart';

/// Shows every saved favourite. Updates instantly when hearts are tapped.
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ListenableBuilder(
        listenable: FavoritesService.instance,
        builder: (context, _) {
          final favorites = FavoritesService.instance.favorites;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Text(
                  'Favourites',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 2, 20, 12),
                child: Text(
                  favorites.isEmpty
                      ? 'Your saved movies live here'
                      : '${favorites.length} saved '
                          '${favorites.length == 1 ? 'movie' : 'movies'}',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ),
              Expanded(
                child: favorites.isEmpty
                    ? const EmptyView(
                        icon: Icons.favorite_border_rounded,
                        title: 'No favourites yet',
                        message:
                            'Tap the heart on any movie to save it here.',
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        gridDelegate: movieGridDelegate,
                        itemCount: favorites.length,
                        itemBuilder: (context, index) {
                          final movie = favorites[index];
                          return MovieCard(
                            // The key keeps cards correct when items are removed.
                            key: ValueKey(movie.id),
                            movie: movie,
                            onTap: () => openDetails(context, movie),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
