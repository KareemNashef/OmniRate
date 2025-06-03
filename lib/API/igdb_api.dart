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
Future<String> fetchReleaseDate(int gameId) async {
  const String url = 'https://api.igdb.com/v4/release_dates';

  final query = '''
    fields human;
    where game = $gameId;
    sort date asc;
    limit 1;
  ''';

  final response = await http.post(
    Uri.parse(url),
    headers: {
      'Client-ID': clientId,
      'Authorization': 'Bearer $bearerToken',
      'Accept': 'application/json',
    },
    body: query,
  );

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    if (data.isNotEmpty && data[0]['human'] != null) {
      return data[0]['human'];
    }
  }

  return 'N/A';
}

Future<String> fetchCoverUrl(int coverId) async {
  final query = '''
    fields url;
    where id = $coverId;
    limit 1;
  ''';

  final response = await http.post(
    Uri.parse('https://api.igdb.com/v4/covers'),
    headers: {
      'Client-ID': clientId,
      'Authorization': 'Bearer $bearerToken',
      'Accept': 'application/json',
    },
    body: query,
  );

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    if (data.isNotEmpty) {
      return data[0]['url'] ?? '';
    }
  }

  return 'N/A';
}

Future<Map<String, String>> fetchGameTime(int gameId) async {
  const String gameTimeUrl = 'https://api.igdb.com/v4/game_time_to_beats';

  final query = '''
    fields hastily, normally, completely;
    where game = $gameId;
    limit 1;
  ''';

  final response = await http.post(
    Uri.parse(gameTimeUrl),
    headers: {
      'Client-ID': clientId,
      'Authorization': 'Bearer $bearerToken',
      'Accept': 'application/json',
    },
    body: query,
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);

    if (data.isEmpty) {
      return {
        'timeHaste': 'N/A',
        'timeNormal': 'N/A',
        'timeComplete': 'N/A',
      };
    }

    final raw = data[0];

    return {
      'timeHaste': (raw['hastily'] ?? 'N/A').toString(),
      'timeNormal': (raw['normally'] ?? 'N/A').toString(),
      'timeComplete': (raw['completely'] ?? 'N/A').toString(),
    };
  } else {
    throw Exception('Failed to fetch game time data');
  }
}

Future<String> fetchCompanyNamesFromInvolved(List<int> involvedCompanyIds) async {
  // Step 1: Get company IDs from involved_companies
  final involvedResponse = await http.post(
    Uri.parse('https://api.igdb.com/v4/involved_companies'),
    headers: {
      'Client-ID': clientId,
      'Authorization': 'Bearer $bearerToken',
      'Accept': 'application/json',
    },
    body: '''
      fields company;
      where id = (${involvedCompanyIds.join(',')});
    ''',
  );

  if (involvedResponse.statusCode != 200) {
    throw Exception('Failed to fetch involved company data');
  }

  final List<dynamic> involvedData = jsonDecode(involvedResponse.body);
  final List<int> companyIds = involvedData
      .map<int>((e) => e['company'] as int)
      .whereType<int>()
      .toList();

  if (companyIds.isEmpty) return 'N/A';

  // Step 2: Get company names
  final companiesResponse = await http.post(
    Uri.parse('https://api.igdb.com/v4/companies'),
    headers: {
      'Client-ID': clientId,
      'Authorization': 'Bearer $bearerToken',
      'Accept': 'application/json',
    },
    body: '''
      fields name;
      where id = (${companyIds.join(',')});
    ''',
  );

  if (companiesResponse.statusCode != 200) {
    throw Exception('Failed to fetch company names');
  }

  final List<dynamic> companiesData = jsonDecode(companiesResponse.body);
  final names = companiesData.map((e) => e['name'].toString()).toList();

  return names.join(', ');
}

Future<String> fetchFirstScreenshotUrl(List<int> screenshotIds) async {
  if (screenshotIds.isEmpty) return 'N/A';

  final int firstId = screenshotIds.first;

  final response = await http.post(
    Uri.parse('https://api.igdb.com/v4/screenshots'),
    headers: {
      'Client-ID': clientId,
      'Authorization': 'Bearer $bearerToken',
      'Accept': 'application/json',
    },
    body: '''
      fields url;
      where id = $firstId;
      limit 1;
    ''',
  );

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    if (data.isNotEmpty && data[0]['url'] != null) {
      return data[0]['url'].toString().replaceAll('t_thumb', 't_screenshot_big');
    }
  }

  return 'N/A';
}


// ========== Main Functions ==========

// Func: getGameEntry
// Input: Game name
// Output: Game object
Future<Game?> getGameEntry(String inName) async {
  try {
    // Step 1: Fetch basic game info
    final gameResponse = await http.post(
      Uri.parse('https://api.igdb.com/v4/games'),
      headers: {
        'Client-ID': clientId,
        'Authorization': 'Bearer $bearerToken',
        'Accept': 'application/json',
      },
      body: '''
        fields name,cover,rating,first_release_date,genres.name,summary,involved_companies,screenshots;
        where name ~ *"$inName"*;
        limit 1;
      ''',
    );

    if (gameResponse.statusCode != 200) throw Exception("Game fetch failed");
    final gameData = jsonDecode(gameResponse.body);
    if (gameData.isEmpty) return null;
    final game = gameData[0];

    final int gameId = game['id'];
    final String name = game['name'] ?? 'N/A';
    final String rating = game['rating'] != null
        ? double.parse(game['rating'].toString()).toStringAsFixed(1)
        : 'N/A';
    final List<String> genres = (game['genres'] as List<dynamic>?)
            ?.map((g) => g['name'].toString())
            .toList() ??
        [];

    final String overview = game['summary'] ?? 'N/A';

    // Step 2: Fetch cover image
    final String thumbnailUrl = await fetchCoverUrl(game['cover']);

    // Step 3: Fetch release date
    final String releaseDate = await fetchReleaseDate(gameId);

    // Step 4: Fetch play times
    final timeMap = await fetchGameTime(gameId);
    final String timeHaste = timeMap['timeHaste'] ?? 'N/A';
    final String timeNormal = timeMap['timeNormal'] ?? 'N/A';
    final String timeComplete = timeMap['timeComplete'] ?? 'N/A';

    // Step 5: Fetch developer name(s)
    String developer = 'N/A';
    if (game['involved_companies'] != null) {
      final List<int> involvedCompanyIds =
          List<int>.from(game['involved_companies']);
      developer = await fetchCompanyNamesFromInvolved(involvedCompanyIds);
    }

    String screenshotUrl = 'N/A';
    if (game['screenshots'] != null) {
      final List<int> screenshotIds = List<int>.from(game['screenshots']);
      screenshotUrl = await fetchFirstScreenshotUrl(screenshotIds);
    }

    // Step 6: Construct and return Game object
    return Game(
      name: name,
      thumbnailUrl: thumbnailUrl,
      rating: rating,
      releaseDate: releaseDate,
      developer: developer,
      genres: genres,
      overview: overview,
      timeHaste: timeHaste,
      timeNormal: timeNormal,
      timeComplete: timeComplete,
    );
  } catch (e) {
    print('Error fetching game data: $e');
    return null;
  }
}



// Func: getFilteredGames
// Input: List<String> genres, String category, String minRating
// Output: List<Game> gamesList - Sized to 20;
Future<List<Game>> getFilteredGames(List<String> inGenres, String inCategory, String inMinRating) async {
  final genreIds = inGenres.map((g) => genreToIDMap[g]).whereType<int>().toList();
  final minRatingDouble = double.tryParse(inMinRating) ?? 0.0;

  final genreQuery = genreIds.isNotEmpty ? "genres = (${genreIds.join(',')}) &" : "";

  final body = '''
    fields name,cover,rating,first_release_date,genres.name,summary,involved_companies,screenshots;
    where $genreQuery rating >= $minRatingDouble;
    sort rating desc;
    limit 20;
  ''';

  final response = await http.post(
    Uri.parse(igdbUrl),
    headers: {
      'Client-ID': clientId,
      'Authorization': 'Bearer $bearerToken',
      'Accept': 'application/json',
    },
    body: body,
  );

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    return Future.wait(data.map((gameData) async => await convertGameFromData(gameData)));
  }

  return [];
}


// Func: getRecentGames
// Input: None
// Output: List<Game> gamesList - Sized to 10;
Future<List<Game>> getRecentGames() async {

}

// Func: getTrendingGames
// Input: None
// Output: List<Game> gamesList - Sized to 10;
Future<List<Game>> getTrendingGames() async {

}

// Func: getTopGames
// Input: None
// Output: List<Game> gamesList - Sized to 10;
Future<List<Game>> getTopGames() async {

}

