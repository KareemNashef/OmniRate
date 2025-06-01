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

// Func: getRecentShows
// Input: None
// Output: List<Show> showsList - Sized to 10;
List<Show> getRecentShows() {}

// Func: getTrendingShows
// Input: None
// Output: List<Show> showsList - Sized to 10;
List<Show> getTrendingShows() {}

// Func: getTopShows
// Input: None
// Output: List<Show> showsList - Sized to 10;
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

// Func: getRecentMovies
// Input: None
// Output: List<Movie> moviesList - Sized to 10;
List<Movie> getRecentMovies() {}

// Func: getTrendingMovies
// Input: None
// Output: List<Movie> moviesList - Sized to 10;
List<Movie> getTrendingMovies() {}

// Func: getTopMovies
// Input: None
// Output: List<Movie> moviesList - Sized to 10;
List<Movie> getTopMovies() {}