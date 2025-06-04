// ==================== TMDB API - Shows And Movies ==================== //
// Documentation: https://developer.themoviedb.org/docs/getting-started
// Call testing: https://www.postman.com/
// API Key: b0660f1133aa5458af9be7244a2988ee

// Flutter imports
// ...

// Local imports
import 'package:omnirate/Database/model_movie.dart';
import 'package:omnirate/Database/model_show.dart';

// ========== Helper Consts ==========

// API Keys and urls
// GenreToIDMap
// ...

// ========== Main Functions - Shows ==========

// Func: getShowEntry
// Input: Show name
// Output: Show object
Show getShowEntry(String inName) {}

// Func: getFilteredShows
// Input: List<String> genres, String category, String minRating
// Output: List<Show> showsList - Sized to 20;
List<Show> getFilteredShows(List<String> inGenres, String inCategory, String inMinRating) {}

// Func: getUpcomingShows
// Input: None
// Output: List<Show> showsList - Sized to 10;
// https://api.themoviedb.org/3/discover/tv?first_air_date.gte=2025-06-04
List<Show> getUpcomingShows() {}

// Func: getLatestShows
// Input: None
// Output: List<Show> showsList - Sized to 10;
// https://api.themoviedb.org/3/discover/tv?first_air_date.gte=2025-04-01
List<Show> getLatestShows() {}

// Func: getTopShows
// Input: None
// Output: List<Show> showsList - Sized to 10;
// https://api.themoviedb.org/3/tv/top_rated
List<Show> getTopShows() {}

// ========== Main Functions - Movies ==========

// Func: getMovieEntry
// Input: Movie name
// Output: Movie object
Movie getMovieEntry(String inName) {}

// Func: getFilteredMovies
// Input: List<String> genres, String category, String minRating
// Output: List<Movie> moviesList - Sized to 20;
List<Movie> getFilteredMovies(List<String> inGenres, String inCategory, String inMinRating) {}

// Func: getUpcomingMovies
// Input: None
// Output: List<Movie> moviesList - Sized to 10;
// https://api.themoviedb.org/3/discover/movie?primary_release_date.gte=2025-06-04&region=US
List<Movie> getUpcomingMovies() {}

// Func: getLatestMovies
// Input: None
// Output: List<Movie> moviesList - Sized to 10;
// https://api.themoviedb.org/3/movie/now_playing
List<Movie> getLatestMovies() {}

// Func: getTopMovies
// Input: None
// Output: List<Movie> moviesList - Sized to 10;
// https://api.themoviedb.org/3/movie/top_rated
List<Movie> getTopMovies() {}