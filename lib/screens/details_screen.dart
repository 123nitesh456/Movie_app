import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/movie.dart';
import '../services/favorites_service.dart';
import '../services/tmdb_service.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';
import '../widgets/movie_card.dart';

/// Full movie details. Shows what we already know instantly (from the list),
/// then fetches genres and runtime from the details endpoint.
class DetailsScreen extends StatefulWidget {
  const DetailsScreen({super.key, required this.movie});

  final Movie movie;

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  late Movie _movie;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _movie = widget.movie;
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final full = await TmdbService.instance.getMovieDetails(widget.movie.id);
      if (!mounted) return;
      setState(() {
        _movie = full;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not load movie details.';
        _loading = false;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    final added = await FavoritesService.instance.toggle(_movie);
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          added ? 'Added to favourites' : 'Removed from favourites',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final backdropUrl = AppConstants.backdropUrl(_movie.backdropPath) ??
        AppConstants.posterUrl(_movie.posterPath, size: 'w780');
    final posterUrl = AppConstants.posterUrl(_movie.posterPath);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 270,
            backgroundColor: AppColors.background,
            automaticallyImplyLeading: false,
            leadingWidth: 64,
            leading: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: _RoundIconButton(
                icon: Icons.arrow_back_rounded,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            actions: [
              ListenableBuilder(
                listenable: FavoritesService.instance,
                builder: (context, _) {
                  final isFavorite =
                      FavoritesService.instance.isFavorite(_movie.id);
                  return _RoundIconButton(
                    icon: isFavorite
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: isFavorite ? AppColors.accent : Colors.white,
                    onPressed: _toggleFavorite,
                  );
                },
              ),
              const SizedBox(width: 16),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (backdropUrl == null)
                    const PosterPlaceholder()
                  else
                    CachedNetworkImage(
                      imageUrl: backdropUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => const PosterPlaceholder(),
                      errorWidget: (_, __, ___) => const PosterPlaceholder(),
                    ),
                  // Fades the image into the page background.
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black45,
                          Colors.transparent,
                          AppColors.background,
                        ],
                        stops: [0, 0.45, 1],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: SizedBox(
                          width: 112,
                          height: 168,
                          child: posterUrl == null
                              ? const PosterPlaceholder()
                              : CachedNetworkImage(
                                  imageUrl: posterUrl,
                                  fit: BoxFit.cover,
                                  placeholder: (_, __) =>
                                      const PosterPlaceholder(),
                                  errorWidget: (_, __, ___) =>
                                      const PosterPlaceholder(),
                                ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _movie.title,
                              style: const TextStyle(
                                fontSize: 24,
                                height: 1.2,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _InfoRow(
                              icon: Icons.star_rounded,
                              iconColor: AppColors.star,
                              text: _movie.voteAverage <= 0
                                  ? 'Not rated yet'
                                  : '${_movie.ratingText} / 10',
                            ),
                            _InfoRow(
                              icon: Icons.calendar_today_rounded,
                              text: _movie.formattedDate,
                            ),
                            if (_movie.runtimeText != null)
                              _InfoRow(
                                icon: Icons.schedule_rounded,
                                text: _movie.runtimeText!,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildStatus(),
                  if (_movie.genres.isNotEmpty) ...[
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _movie.genres
                          .map(
                            (genre) => Chip(
                              label: Text(genre),
                              backgroundColor: AppColors.surface,
                              side: BorderSide.none,
                              labelStyle: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 20),
                  ],
                  ListenableBuilder(
                    listenable: FavoritesService.instance,
                    builder: (context, _) {
                      final isFavorite =
                          FavoritesService.instance.isFavorite(_movie.id);
                      return SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _toggleFavorite,
                          icon: Icon(
                            isFavorite
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                          ),
                          label: Text(
                            isFavorite
                                ? 'Remove from favourites'
                                : 'Add to favourites',
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: isFavorite
                                ? AppColors.surfaceLight
                                : AppColors.accent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'Overview',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _movie.overview.isEmpty
                        ? 'No overview available for this movie.'
                        : _movie.overview,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.55,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Small loading / error line shown while the extra details are fetched.
  Widget _buildStatus() {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.only(bottom: 20),
        child: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.accent,
              ),
            ),
            SizedBox(width: 10),
            Text(
              'Loading details...',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }
    if (_error != null) {
      return Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.fromLTRB(14, 8, 8, 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: AppColors.accent),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _error!,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            TextButton(
              onPressed: _loadDetails,
              style: TextButton.styleFrom(foregroundColor: AppColors.accent),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    required this.onPressed,
    this.color = Colors.white,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, color: color, size: 22),
      style: IconButton.styleFrom(
        backgroundColor: Colors.black.withValues(alpha: 0.55),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text, this.iconColor});

  final IconData icon;
  final String text;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 17, color: iconColor ?? AppColors.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
