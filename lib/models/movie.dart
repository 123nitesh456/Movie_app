/// A movie as returned by TMDB list endpoints (trending, popular, search)
/// and the details endpoint. Fields that only exist on the details endpoint
/// (genres, runtime) are empty/null for list results.
class Movie {
  const Movie({
    required this.id,
    required this.title,
    this.posterPath,
    this.backdropPath,
    this.overview = '',
    this.releaseDate = '',
    this.voteAverage = 0,
    this.genres = const [],
    this.runtime,
  });

  final int id;
  final String title;
  final String? posterPath;
  final String? backdropPath;
  final String overview;
  final String releaseDate;
  final double voteAverage;
  final List<String> genres;
  final int? runtime;

  /// Works for both the TMDB response and our own saved favourites JSON.
  factory Movie.fromJson(Map<String, dynamic> json) {
    final rawGenres = json['genres'];
    final genres = <String>[];
    if (rawGenres is List) {
      for (final g in rawGenres) {
        // TMDB details: [{"id": 28, "name": "Action"}]
        // Saved favourites: ["Action"]
        genres.add(g is Map ? g['name'].toString() : g.toString());
      }
    }

    return Movie(
      id: json['id'] as int,
      title: (json['title'] ?? json['name'] ?? 'Untitled').toString(),
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      overview: (json['overview'] ?? '').toString(),
      releaseDate: (json['release_date'] ?? '').toString(),
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0,
      genres: genres,
      runtime: (json['runtime'] as num?)?.toInt(),
    );
  }

  /// Used to save favourites in SharedPreferences.
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'poster_path': posterPath,
        'backdrop_path': backdropPath,
        'overview': overview,
        'release_date': releaseDate,
        'vote_average': voteAverage,
        'genres': genres,
        'runtime': runtime,
      };

  /// "7.8" or "NR" (not rated) when TMDB has no votes yet.
  String get ratingText =>
      voteAverage <= 0 ? 'NR' : voteAverage.toStringAsFixed(1);

  /// "12 Mar 2024" or a fallback when the date is missing.
  String get formattedDate {
    final date = DateTime.tryParse(releaseDate);
    if (date == null) return 'Release date TBA';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  /// "2h 15m", or null when runtime is unknown.
  String? get runtimeText {
    final minutes = runtime;
    if (minutes == null || minutes <= 0) return null;
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h == 0) return '${m}m';
    return m == 0 ? '${h}h' : '${h}h ${m}m';
  }
}
