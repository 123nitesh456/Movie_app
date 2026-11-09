# CineScope – Movie Discovery App

A Flutter app that lets you discover trending and popular movies, search by title, read details, and save favourites that stay on your device. Built for **DevSource DevCamp 2.0 – Week 3, Project 3 (Movie App with API Integration)**.

## Features

- Trending (this week) and Popular movies with posters, titles, release dates and ratings
- Infinite scrolling: more movies load as you reach the bottom
- Search by title (debounced), with a "no results" state and empty-input handling
- Details screen: backdrop, poster, title, rating, release date, genres, runtime, overview
- Add / remove favourites from cards or the details screen
- Favourites are saved with SharedPreferences and survive app restarts
- Loading indicators, friendly error messages and Retry buttons everywhere
- Dark navy theme, rounded cards, smooth page transitions, responsive grid

## Technologies

- Flutter and Dart
- [TMDB API](https://www.themoviedb.org/documentation/api) (REST + JSON)
- `http` – API requests
- `shared_preferences` – local favourites storage
- `cached_network_image` – fast, cached posters

## Project structure

```
lib/
├─ main.dart                    app entry + bottom navigation
├─ models/movie.dart            Movie model + JSON parsing
├─ services/
│  ├─ tmdb_service.dart         API calls and error handling
│  └─ favorites_service.dart    favourites + SharedPreferences
├─ screens/                     Home, Search, Details, Favourites
├─ widgets/                     MovieCard, PagedMovieGrid, Loading/Error/Empty views
└─ utils/
   ├─ app_theme.dart            colours and dark theme
   ├─ constants.dart            URLs, keys, grid layout
   ├─ navigation.dart           page transition helper
   ├─ api_config.example.dart   committed example (no real key)
   └─ api_config.dart           YOUR key (git-ignored)
```

## Installation

1. Install [Flutter](https://docs.flutter.dev/get-started/install) and run `flutter doctor`.
2. Clone this repository and open it in VS Code.
3. Install packages:
   ```
   flutter pub get
   ```

## API setup (TMDB key)

1. Create a free account at [themoviedb.org](https://www.themoviedb.org/signup).
2. Go to **Settings → API** and request a developer key (choose personal/educational use).
3. Copy the **API Key** (the shorter v3 key, not the "Read Access Token").
4. Copy `lib/utils/api_config.example.dart` to `lib/utils/api_config.dart`.
5. Open `api_config.dart` and replace `YOUR_TMDB_API_KEY_HERE` with your key.

`lib/utils/api_config.dart` is listed in `.gitignore`, so your key is never committed.

## Running the app

```
flutter run
```

Pick an Android emulator or a USB-connected phone. If you build a **release** APK, make sure
`android/app/src/main/AndroidManifest.xml` contains:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

## Demo and screenshots

- Screenshots: see the `screenshots/` folder
- Demo video: _add your link here_

## Credits

This product uses the TMDB API but is not endorsed or certified by TMDB.


## Screenshots & Demo Video
you can view all application screenshots and the complete demo video here:
https://drive.google.com/drive/folders/1o0yRMrZlzXbdotL7EmecqQcHYj3kiiiK?usp=sharing
