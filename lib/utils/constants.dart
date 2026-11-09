import 'package:flutter/material.dart';

/// App-wide constants (URLs, storage keys, layout values).
class AppConstants {
  AppConstants._();

  static const String appName = 'CineScope';

  // TMDB endpoints
  static const String baseUrl = 'https://api.themoviedb.org/3';
  static const String imageBaseUrl = 'https://image.tmdb.org/t/p';

  // Local storage key used by SharedPreferences
  static const String favoritesKey = 'favorite_movies';

  /// Returns a full poster URL, or null when the movie has no poster.
  static String? posterUrl(String? path, {String size = 'w500'}) {
    if (path == null || path.isEmpty) return null;
    return '$imageBaseUrl/$size$path';
  }

  /// Returns a full backdrop URL, or null when the movie has no backdrop.
  static String? backdropUrl(String? path, {String size = 'w780'}) {
    if (path == null || path.isEmpty) return null;
    return '$imageBaseUrl/$size$path';
  }
}

/// Responsive grid used by Home, Search and Favourites.
/// Columns are added automatically as the screen gets wider.
const SliverGridDelegateWithMaxCrossAxisExtent movieGridDelegate =
    SliverGridDelegateWithMaxCrossAxisExtent(
  maxCrossAxisExtent: 190,
  mainAxisSpacing: 18,
  crossAxisSpacing: 14,
  childAspectRatio: 0.54,
);
