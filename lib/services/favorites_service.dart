import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/movie.dart';
import '../utils/constants.dart';

/// Keeps the favourites list in memory and saves it to SharedPreferences.
/// Extends [ChangeNotifier] so every screen updates when a heart is tapped.
class FavoritesService extends ChangeNotifier {
  FavoritesService._();

  static final FavoritesService instance = FavoritesService._();

  final List<Movie> _favorites = [];

  List<Movie> get favorites => List.unmodifiable(_favorites);

  bool isFavorite(int movieId) => _favorites.any((m) => m.id == movieId);

  /// Call once at app start (see main.dart).
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getStringList(AppConstants.favoritesKey) ?? [];
      _favorites.clear();
      for (final item in saved) {
        try {
          _favorites.add(Movie.fromJson(json.decode(item)));
        } catch (_) {
          // Skip a corrupted entry instead of crashing.
        }
      }
      notifyListeners();
    } catch (_) {
      // If storage fails, the app simply starts with no favourites.
    }
  }

  /// Adds the movie if it is not a favourite, otherwise removes it.
  /// Returns true when the movie is now a favourite.
  Future<bool> toggle(Movie movie) async {
    final wasFavorite = isFavorite(movie.id);
    if (wasFavorite) {
      _favorites.removeWhere((m) => m.id == movie.id);
    } else {
      _favorites.insert(0, movie); // newest first
    }
    notifyListeners();
    await _save();
    return !wasFavorite;
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        AppConstants.favoritesKey,
        _favorites.map((m) => json.encode(m.toJson())).toList(),
      );
    } catch (_) {
      // Ignore write errors; the in-memory list still works this session.
    }
  }
}
