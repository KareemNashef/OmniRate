// ==================== IGDB API - Video Games ==================== //
// Documentation: https://api-docs.igdb.com/#getting-started
// Call testing: https://www.postman.com/
// Client ID: uy1ewiwcafvxgao5jq3bxhme0z20tx
// Bearer token: 2bf4mjgv69yeh7buax0ijizt6bsg5u


// Flutter imports
// ...

// Local imports
import 'package:omnirate/Database/model_game.dart';


// ========== Helper Consts ==========

// API Keys and urls
// GenreToIDMap
// ...

// ========== Main Functions ==========

// Func: getGameEntry
// Input: Game name
// Output: Game object
Game getGameEntry(String inName) {}

// Func: getFilteredGames
// Input: List<String> genres, String category, String minRating
// Output: List<Game> gamesList - Sized to 20;
List<Game> getFilteredGames(List<String> inGenres, String inCategory, String inMinRating) {}

// Func: getRecentGames
// Input: None
// Output: List<Game> gamesList - Sized to 10;
List<Game> getRecentGames() {}

// Func: getTrendingGames
// Input: None
// Output: List<Game> gamesList - Sized to 10;
List<Game> getTrendingGames() {}

// Func: getTopGames
// Input: None
// Output: List<Game> gamesList - Sized to 10;
List<Game> getTopGames() {}

