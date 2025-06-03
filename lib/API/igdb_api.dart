// ==================== IGDB API - Video Games ==================== //
// Documentation: https://api-docs.igdb.com/#getting-started
// Call testing: https://www.postman.com/
// Client ID: uy1ewiwcafvxgao5jq3bxhme0z20tx
// Bearer token: 2bf4mjgv69yeh7buax0ijizt6bsg5u

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:omnirate/Database/model_game.dart';

// ========== Helper Consts ==========
const String clientId = 'uy1ewiwcafvxgao5jq3bxhme0z20tx';
const String bearerToken = '2bf4mjgv69yeh7buax0ijizt6bsg5u';
const String igdbUrl = 'https://api.igdb.com/v4/games';

Map<String, int> genreToIDMap = {
  "Point-and-click": 2,
  "Fighting": 4,
  "Shooter": 5,
  "Music": 7,
  "Platform": 8,
  "Puzzle": 9,
  "Racing": 10,
  "Real Time Strategy (RTS)": 11,
  "Role-playing (RPG)": 12,
  "Simulator": 13,
  "Sport": 14,
  "Strategy": 15,
  "Turn-based strategy (TBS)": 16,
  "Tactical": 24,
  "Hack and slash/Beat 'em up": 25,
  "Quiz/Trivia": 26,
  "Pinball": 30,
  "Adventure": 31,
  "Indie": 32,
  "Arcade": 33,
  "Visual Novel": 34,
  "Card & Board Game": 35,
  "MOBA": 36,
};

// ========== Helper Function ==========
Future<List<Game>> _fetchGames(String query, {int limit = 10}) async {
  final response = await http.post(
    Uri.parse(igdbUrl),
    headers: {
      'Client-ID': clientId,
      'Authorization': 'Bearer $bearerToken',
      'Accept': 'application/json',
    },
    body: query,
  );

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => Game.fromMap(json)).toList();
  } else {
    throw Exception('Failed to load games');
  }
}

// ========== Main Functions ==========

// Func: getGameEntry
// Input: Game name
// Output: Game object
Future<Game?> getGameEntry(String inName) async {
  final query = '''
    fields name,cover.url,genres.name,rating,summary;
    where name ~ *"$inName"*;
    limit 1;
  ''';
  final games = await _fetchGames(query, limit: 1);
  return games.isNotEmpty ? games.first : null;
}

// Func: getFilteredGames
// Input: List<String> genres, String category, String minRating
// Output: List<Game> gamesList - Sized to 20;
Future<List<Game>> getFilteredGames(
  List<String> inGenres,
  String inCategory,
  String inMinRating,
) async {
  // Build genre filter
  final genreIds =
      inGenres.map((g) => genreToIDMap[g]).whereType<int>().toList();
  final genreFilter =
      genreIds.isNotEmpty ? 'genres = (${genreIds.join(",")});' : '';
  final categoryFilter = inCategory.isNotEmpty ? 'category = $inCategory;' : '';
  final ratingFilter = inMinRating.isNotEmpty ? 'rating >= $inMinRating;' : '';

  final query = '''
    fields name,cover.url,genres.name,rating,summary;
    $genreFilter
    $categoryFilter
    $ratingFilter
    limit 20;
  ''';
  return await _fetchGames(query, limit: 20);
}

// Func: getRecentGames
// Input: None
// Output: List<Game> gamesList - Sized to 10;
Future<List<Game>> getRecentGames() async {
  final query = '''
    fields name,cover.url,genres.name,rating,summary,first_release_date;
    sort first_release_date desc;
    limit 10;
  ''';
  return await _fetchGames(query, limit: 10);
}

// Func: getTrendingGames
// Input: None
// Output: List<Game> gamesList - Sized to 10;
Future<List<Game>> getTrendingGames() async {
  final query = '''
    fields name,cover.url,genres.name,rating,summary,popularity;
    sort popularity desc;
    limit 10;
  ''';
  return await _fetchGames(query, limit: 10);
}

// Func: getTopGames
// Input: None
// Output: List<Game> gamesList - Sized to 10;
Future<List<Game>> getTopGames() async {
  final query = '''
    fields name,cover.url,genres.name,rating,summary;
    sort rating desc;
    where rating != null;
    limit 10;
  ''';
  return await _fetchGames(query, limit: 10);
}
