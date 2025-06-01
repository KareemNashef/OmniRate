// ==================== IGDB API - Video Games ==================== //
// Documentation: https://api-docs.igdb.com/#getting-started
// Call testing: https://www.postman.com/

// Flutter imports
// ...

// Local imports
// ...


// ========== Helper Consts ==========

// API Keys and urls
// GenreToIDMap
// ...

// ========== Main Functions ==========

// Func: getGameEntry
// Input: Game name
// Output for now: This list
// String name;
// String thumbnailUrl;
// String rating;
// String releaseDate;
// String developer;
// List<String> genres;
// String overview;
// String timeHaste;
// String timeNormal;
// String timeComplete;
List<String> getGameEntry(String inName) {}

// Func: getFilteredGames
// Input: List<String> genres, String category, String minRating
// Output: List<String> gamesList - Sized to 20;
List<String> getFilteredGames(List<String> inGenres, String inCategory, String inMinRating) {}

// Func: getRecentGames
// Input: None
// Output: List<String> gamesList - Sized to 10;
List<String> getRecentGames() {}

// Func: getTrendingGames
// Input: None
// Output: List<String> gamesList - Sized to 10;
List<String> getTrendingGames() {}

// Func: getTopGames
// Input: None
// Output: List<String> gamesList - Sized to 10;
List<String> getTopGames() {}

