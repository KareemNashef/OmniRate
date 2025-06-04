// ==================== IGDB API - Video Games ==================== //
// Documentation: https://api-docs.igdb.com/#getting-started
// Call testing: https://www.postman.com/
// Client ID: uy1ewiwcafvxgao5jq3bxhme0z20tx
// Bearer token: 2bf4mjgv69yeh7buax0ijizt6bsg5u

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:omnirate/Database/model_game.dart';

// ========== Helper Consts ==========

// API Keys
final igdbHeaders = {
  'Client-ID': 'uy1ewiwcafvxgao5jq3bxhme0z20tx',
  'Authorization': 'Bearer 2bf4mjgv69yeh7buax0ijizt6bsg5u',
  'Accept': 'application/json',
};

// Release date URL
const String releaseDateUrl = 'https://api.igdb.com/v4/release_dates';

// Cover art URL
const String coverArtUrl = 'https://api.igdb.com/v4/covers';

// Time to beat URL
const String gameTimeUrl = 'https://api.igdb.com/v4/game_time_to_beats';

// Involved companies URL
const String involvedCompaniesUrl =
    'https://api.igdb.com/v4/involved_companies';

// Company names URL
const String companyNamesUrl = 'https://api.igdb.com/v4/companies';

// Artworks URL
const String artworksUrl = 'https://api.igdb.com/v4/artworks';

// ========== Helper Function ==========

// Post request handler
Future<http.Response> postRequest(String inURL, String inQuery) async {
  return await http.post(Uri.parse(inURL), headers: igdbHeaders, body: inQuery);
}

// Fetch release date
Future<String> fetchReleaseDate(int gameId) async {
  // Generate the query
  final query = '''
    fields human;
    where game = $gameId;
    sort date asc;
    limit 1;
  ''';

  // Send the POST request
  final response = await postRequest(releaseDateUrl, query);

  // Process the response
  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    if (data.isNotEmpty && data[0]['human'] != null) {
      return data[0]['human'];
    }
  }

  return 'N/A';
}

// Fetch cover
Future<String> fetchCoverUrl(int coverId) async {
  // Generate the query
  final query = '''
    fields image_id;
    where id = $coverId;
    limit 1;
  ''';

  // Send the POST request
  final response = await postRequest(coverArtUrl, query);

  // Process the response
  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    if (data.isNotEmpty) {
      final imageId = data[0]['image_id'];
      return 'https://images.igdb.com/igdb/image/upload/t_cover_big/$imageId.webp';
    }
  }

  return 'N/A';
}

// Fetch game time to beat
Future<Map<String, String>> fetchGameTime(int gameId) async {
  // Generate the query
  final query = '''
    fields hastily, normally, completely;
    where game_id = $gameId;
  ''';

  // Send the POST request
  final response = await postRequest(gameTimeUrl, query);

  // Process the response
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);

    if (data.isEmpty) {
      return {'timeHaste': 'N/A', 'timeNormal': 'N/A', 'timeComplete': 'N/A'};
    }

    // Convert from seconds to hours
    final raw = data[0];
    return {
      'timeHaste':
          raw['hastily'] != null
              ? (raw['hastily'] / 3600).toStringAsFixed(2)
              : 'N/A',
      'timeNormal':
          raw['normally'] != null
              ? (raw['normally'] / 3600).toStringAsFixed(2)
              : 'N/A',
      'timeComplete':
          raw['completely'] != null
              ? (raw['completely'] / 3600).toStringAsFixed(2)
              : 'N/A',
    };
  } else {
    throw Exception('Failed to fetch game time data');
  }
}

// Fetch company names
Future<String> fetchCompanyNamesFromInvolved(
  List<int> involvedCompanyIds,
) async {
  // Generate the involved companies query
  final involvedQuery = '''
    fields company;
    where id = (${involvedCompanyIds.join(',')});
  ''';

  // Send the POST request
  final involvedResponse = await postRequest(
    involvedCompaniesUrl,
    involvedQuery,
  );

  // Process the response
  if (involvedResponse.statusCode != 200) {
    throw Exception('Failed to fetch involved company data');
  }

  final List<dynamic> involvedData = jsonDecode(involvedResponse.body);
  final List<int> companyIds =
      involvedData
          .map<int>((e) => e['company'] as int)
          .whereType<int>()
          .toList();

  if (companyIds.isEmpty) return 'N/A';

  // Generate the company names query
  final companyQuery = '''
    fields name;
    where id = (${companyIds.join(',')});
  ''';

  // Send the POST request
  final companyResponse = await postRequest(companyNamesUrl, companyQuery);

  // Process the response
  if (companyResponse.statusCode != 200) {
    throw Exception('Failed to fetch company names');
  }

  final List<dynamic> companiesData = jsonDecode(companyResponse.body);
  final names = companiesData.map((e) => e['name'].toString()).toList();

  return names.join(', ');
}

// Fetch game artwork
Future<String> fetchArtworkUrl(int artworkId) async {
  // Generate the query
  final query = '''
    fields url;
    where id = $artworkId;
    limit 1;
  ''';

  // Send the POST request
  final response = await postRequest(artworksUrl, query);

  // Process the response
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    if (data.isNotEmpty && data[0]['url'] != null) {
      // Get the highest resolution image
      return data[0]['url'].toString().replaceAll(
        't_thumb',
        't_screenshot_huge',
      );
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
    // 1. Fetch basic game info

    // 1.1. Generate the query
    final query = '''
      fields name,cover,rating,first_release_date,genres.name,summary,involved_companies,artworks;
      where name = "$inName";
      limit 1;
    ''';

    // 1.2. Send the POST request
    final gameResponse = await postRequest(
      'https://api.igdb.com/v4/games',
      query,
    );

    // 1.3. Process the response
    if (gameResponse.statusCode != 200) throw Exception("Game fetch failed");
    final gameData = jsonDecode(gameResponse.body);
    if (gameData.isEmpty) return null;
    final game = gameData[0];

    final int gameId = game['id'];
    final String name = game['name'] ?? 'N/A';
    final double rating =
        game['rating'] != null
            ? double.parse(
              (double.parse(game['rating'].toString()) / 10).toStringAsFixed(1),
            )
            : 0.0;
    final List<String> genres =
        (game['genres'] as List<dynamic>?)
            ?.map((g) => g['name'].toString())
            .toList() ??
        [];
    final String overview = game['summary'] ?? 'N/A';

    // 2. Fetch cover image
    final String thumbnailUrl = await fetchCoverUrl(game['cover']);

    // 3. Fetch release date
    final String releaseDate = await fetchReleaseDate(gameId);

    // 4. Fetch play times
    final timeMap = await fetchGameTime(gameId);
    final String timeHaste = timeMap['timeHaste'] ?? 'N/A';
    final String timeNormal = timeMap['timeNormal'] ?? 'N/A';
    final String timeComplete = timeMap['timeComplete'] ?? 'N/A';

    // 5. Fetch developer name(s)
    String developer = 'N/A';
    if (game['involved_companies'] != null) {
      final List<int> involvedCompanyIds = List<int>.from(
        game['involved_companies'],
      );
      developer = await fetchCompanyNamesFromInvolved(involvedCompanyIds);
    }

    // 6. Fetch game artwork
    String artworkUrl = 'N/A';
    if (game['artworks'] != null && game['artworks'].isNotEmpty) {
      artworkUrl = await fetchArtworkUrl(game['artworks'][0]);
    }

    // 7. Construct and return Game object
    return Game(
      name: name,
      thumbnailUrl: thumbnailUrl,
      artworkUrl: artworkUrl,
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
// Future<List<Game>> getFilteredGames(List<String> inGenres, String inCategory, String inMinRating) async {
//   final genreIds = inGenres.map((g) => genreToIDMap[g]).whereType<int>().toList();
//   final minRatingDouble = double.tryParse(inMinRating) ?? 0.0;
// 
//   final genreQuery = genreIds.isNotEmpty ? "genres = (${genreIds.join(',')}) &" : "";
// 
//   final body = '''
//     fields name,cover,rating,first_release_date,genres.name,summary,involved_companies,screenshots;
//     where $genreQuery rating >= $minRatingDouble;
//     sort rating desc;
//     limit 20;
//   ''';
// 
//   final response = await http.post(
//     Uri.parse(igdbUrl),
//     headers: {
//       'Client-ID': clientId,
//       'Authorization': 'Bearer $bearerToken',
//       'Accept': 'application/json',
//     },
//     body: body,
//   );
// 
//   if (response.statusCode == 200) {
//     final List<dynamic> data = jsonDecode(response.body);
//     return Future.wait(data.map((gameData) async => await convertGameFromData(gameData)));
//   }
// 
//   return [];
// }


// Func: getUpcomingGames
// Input: None
// Output: List<Game> gamesList - Sized to 10;
// Future<List<Game>> getUpcomingGames() async {
// 
// }

// Func: getLatestGames
// Input: None
// Output: List<Game> gamesList - Sized to 10;
// Future<List<Game>> getLatestGames() async {
// 
// }

// Func: getTopGames
// Input: None
// Output: List<Game> gamesList - Sized to 10;
// Future<List<Game>> getTopGames() async {
// 
// }

