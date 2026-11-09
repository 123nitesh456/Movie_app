/// EXAMPLE configuration file (safe to commit).
///
/// Setup:
/// 1. Copy this file to `api_config.dart` in the same folder.
/// 2. Replace the placeholder below with your own TMDB API key (v3 auth).
/// 3. Never commit `api_config.dart` (it is listed in .gitignore).
class ApiConfig {
  ApiConfig._();

  static const String tmdbApiKey = 'YOUR_TMDB_API_KEY_HERE';
}
