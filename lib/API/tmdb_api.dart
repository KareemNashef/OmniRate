// ==================== TMDB API - Shows And Movies ==================== //
// Documentation: https://developer.themoviedb.org/docs/getting-started
// Call testing: https://www.postman.com/

// Flutter imports
// ...

// Local imports
// ...

// ========== Helper Consts ==========

// API Keys and urls
// GenreToIDMap
// ...

// ========== Main Functions - Shows ==========

// Func: getShowEntry
// Input: Show name
// Output for now: This list
// String name;
// String thumbnailUrl;
// String rating;
// String releaseStatus;
// String firstAir;
// String lastAir;
// String episodesNum;
// String seasonsNum;
// List<String> genres;
// String overview;
// List<String> seasonsNames;
// List<String> seasonsThumbnailsUrls;
// List<String> seasonsAirDates;
// List<String> seasonsEpisodeCounts;
// List<String> seasonsOvervies;
List<String> getShowEntry(String inName) {}

// Func: getFilteredShows
// Input: List<String> genres, String category, String minRating
// Output: List<String> showsList - Sized to 20;
List<String> getFilteredShows(List<String> inGenres, String inCategory, String inMinRating) {}

// Func: getRecentShows
// Input: None
// Output: List<String> showsList - Sized to 10;
List<String> getRecentShows() {}

// Func: getTrendingShows
// Input: None
// Output: List<String> showsList - Sized to 10;
List<String> getTrendingShows() {}

// Func: getTopShows
// Input: None
// Output: List<String> showsList - Sized to 10;
List<String> getTopShows() {}

// ========== Main Functions - Movies ==========

// Func: getMovieEntry
// Input: Movie name
// Output for now: This list
// String name;
// String thumbnailUrl;
// String rating;
// List<String> genres;
// String overview;
// String budget;
// String revenue;
List<String> getMovieEntry(String inName) {}

// Func: getFilteredMovies
// Input: List<String> genres, String category, String minRating
// Output: List<String> moviesList - Sized to 20;
List<String> getFilteredMovies(List<String> inGenres, String inCategory, String inMinRating) {}

// Func: getRecentMovies
// Input: None
// Output: List<String> moviesList - Sized to 10;
List<String> getRecentMovies() {}

// Func: getTrendingMovies
// Input: None
// Output: List<String> moviesList - Sized to 10;
List<String> getTrendingMovies() {}

// Func: getTopMovies
// Input: None
// Output: List<String> moviesList - Sized to 10;
List<String> getTopMovies() {}