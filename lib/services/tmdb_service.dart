import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/movie.dart';
import '../utils/api_config.dart';
import '../utils/constants.dart';

/// An error with a message that is safe to show to the user.
class ApiException implements Exception {
  ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// One page of results from a paginated TMDB endpoint.
class MoviePage {
  const MoviePage({
    required this.movies,
    required this.page,
    required this.totalPages,
  });

  final List<Movie> movies;
  final int page;
  final int totalPages;

  bool get hasMore => page < totalPages;
}

class TmdbService {
  TmdbService({http.Client? client}) : _client = client ?? http.Client();

  /// Shared instance used by the screens.
  static final TmdbService instance = TmdbService();

  final http.Client _client;

  Future<MoviePage> getTrendingMovies({int page = 1}) async {
    final data = await _get('/trending/movie/week', {'page': '$page'});
    return _parsePage(data);
  }

  Future<MoviePage> getPopularMovies({int page = 1}) async {
    final data = await _get('/movie/popular', {'page': '$page'});
    return _parsePage(data);
  }

  Future<MoviePage> searchMovies(String query, {int page = 1}) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return const MoviePage(movies: [], page: 1, totalPages: 1);
    }
    final data = await _get('/search/movie', {
      'query': trimmed,
      'page': '$page',
      'include_adult': 'false',
    });
    return _parsePage(data);
  }

  Future<Movie> getMovieDetails(int id) async {
    final data = await _get('/movie/$id');
    return Movie.fromJson(data);
  }

  MoviePage _parsePage(Map<String, dynamic> data) {
    final results = (data['results'] as List?) ?? const [];
    final movies = results
        .map((item) => Movie.fromJson(item as Map<String, dynamic>))
        .toList();
    return MoviePage(
      movies: movies,
      page: (data['page'] as num?)?.toInt() ?? 1,
      totalPages: (data['total_pages'] as num?)?.toInt() ?? 1,
    );
  }

  /// Central GET helper: builds the URL, adds the API key, and turns every
  /// failure into a friendly [ApiException].
  Future<Map<String, dynamic>> _get(
    String path, [
    Map<String, String> params = const {},
  ]) async {
    final key = ApiConfig.tmdbApiKey.trim();
    if (key.isEmpty || key == 'YOUR_TMDB_API_KEY_HERE') {
      throw ApiException(
        'TMDB API key is missing. Add it to lib/utils/api_config.dart.',
      );
    }

    final uri = Uri.parse('${AppConstants.baseUrl}$path').replace(
      queryParameters: {'api_key': key, 'language': 'en-US', ...params},
    );

    try {
      final response = await _client.get(uri).timeout(
            const Duration(seconds: 15),
          );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }
      if (response.statusCode == 401) {
        throw ApiException('Invalid TMDB API key. Please check your setup.');
      }
      if (response.statusCode == 404) {
        throw ApiException('We could not find what you were looking for.');
      }
      if (response.statusCode == 429) {
        throw ApiException('Too many requests. Please wait a moment.');
      }
      throw ApiException(
        'Server error (${response.statusCode}). Please try again.',
      );
    } on TimeoutException {
      throw ApiException('The request timed out. Please try again.');
    } on SocketException {
      throw ApiException('No internet connection. Check your network.');
    } on http.ClientException {
      throw ApiException('No internet connection. Check your network.');
    } on FormatException {
      throw ApiException('Received unexpected data from the server.');
    }
  }
}
