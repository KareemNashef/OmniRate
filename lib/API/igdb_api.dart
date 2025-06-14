// ==================== IGDB API - Video Games ==================== //

// Flutter imports
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';

// Local imports
import 'package:omnirate/Database/model_game.dart';
import 'package:omnirate/Database/database_helper.dart';
import 'package:omnirate/Shared/utils.dart';
import 'package:omnirate/API/api_helpers.dart';

// ========== Helper Functions ========== //

Future<http.Response> postRequest(String inURL, String inQuery) async {
  // Wait for rate limit
  await RateLimiter.waitForRateLimit();

  // Send the request
  return await http.post(Uri.parse(inURL), headers: igdbHeaders, body: inQuery);
}

String timestampToDate(int? timestamp) {
  if (timestamp == null) return 'N/A';

  // Convert timestamp to date
  final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);

  // Convert to YYYY-MM-DD format
  return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
}

Future<List<Game>> processAndCacheGameList(List<dynamic> rawGamesData) async {
  // Initialize list
  List<Game> readyGamesList = [];
  if (rawGamesData.isEmpty) return readyGamesList;

  // Initialize lists
  List<Game> gamesToCacheEventually = []; // Games to cache eventually
  List<dynamic> gamesToProcessFromApi = []; // Games to fetch from API

  // Step 1: Check if any game is in cache
  for (var rawGameData in rawGamesData) {
    final String? id = rawGameData['id']?.toString();

    if (id == null || id == '0') {
      continue;
    }

    Game? existingGame = await HiveHelper.getGameByID(id);
    if (existingGame != null) {
      // Game found in cache, use its data directly
      readyGamesList.add(existingGame);
    } else {
      // Game not in cache, add its raw data to the list for API processing
      gamesToProcessFromApi.add(rawGameData);
    }
  }

  // If all games were found in cache, we're done with API calls for this list
  if (gamesToProcessFromApi.isEmpty) {
    return readyGamesList;
  }

  // Step 2: Batch fetch game data from API
  List<int> gameIdsToFetch =
      gamesToProcessFromApi.map<int>((g) => g['id'] as int).toList();
  List<int> coverIdsToFetch =
      gamesToProcessFromApi.map<int>((g) => (g['cover'] ?? 0) as int).toList();
  List<int> artworkIdsToFetch =
      gamesToProcessFromApi.map<int>((g) {
        final arts = g['artworks'];
        return (arts != null && arts.isNotEmpty ? arts[0] : 0) as int;
      }).toList();

  Map<int, List<int>> gameToInvolvedCompanyIdsMapForFetching = {};
  for (var gameData in gamesToProcessFromApi) {
    if (gameData['id'] != null && gameData['involved_companies'] != null) {
      gameToInvolvedCompanyIdsMapForFetching[gameData['id']
          as int] = List<int>.from(gameData['involved_companies']);
    } else if (gameData['id'] != null) {
      gameToInvolvedCompanyIdsMapForFetching[gameData['id'] as int] = [];
    }
  }

  // Perform batch fetches concurrently for the filtered list
  final EagerFuture<Map<int, String>> coverUrlsFuture = EagerFuture(
    batchFetchCoverUrls(coverIdsToFetch),
  );
  final EagerFuture<Map<int, String>> artworkUrlsFuture = EagerFuture(
    batchFetchArtworkUrls(artworkIdsToFetch),
  );
  final EagerFuture<Map<int, Map<String, String>>> gameTimesFuture =
      EagerFuture(batchFetchGameTimes(gameIdsToFetch));
  final EagerFuture<Map<int, String>> developerNamesFuture = EagerFuture(
    batchFetchDeveloperNames(gameToInvolvedCompanyIdsMapForFetching),
  );

  final results = await Future.wait([
    coverUrlsFuture,
    artworkUrlsFuture,
    gameTimesFuture,
    developerNamesFuture,
  ]);

  final Map<int, String> fetchedCoverUrls = results[0] as Map<int, String>;
  final Map<int, String> fetchedArtworkUrls = results[1] as Map<int, String>;
  final Map<int, Map<String, String>> fetchedGameTimes =
      results[2] as Map<int, Map<String, String>>;
  final Map<int, String> fetchedDeveloperNames = results[3] as Map<int, String>;

  // ----- Step 3: Construct Game objects for API-fetched games and add to cache list -----
  for (var gameData in gamesToProcessFromApi) {
    final String gameId = gameData['id'].toString();
    final String name = gameData['name'] ?? 'N/A';

    // Data from initial fetch (gamesToProcessFromApi contains this)
    final String rating =
        gameData['rating'] != null
            ? (double.parse(gameData['rating'].toString()) / 10)
                .toStringAsFixed(1)
            : '0.0';

    final List<String> genres =
        (gameData['genres'] as List<dynamic>?)
            ?.map((g) => g['name'].toString())
            .toList() ??
        [];

    final String overview = gameData['summary'] ?? 'N/A';

    final String releaseDate = timestampToDate(gameData['first_release_date']);

    // Data from batch fetches
    final String thumbnailUrl =
        fetchedCoverUrls[gameData['cover'] ?? 0] ?? gamesMissingCoverUrl;
    final String artworkUrl =
        fetchedArtworkUrls[(gameData['artworks'] != null &&
                gameData['artworks'].isNotEmpty
            ? gameData['artworks'][0]
            : 0)] ??
        'N/A';

    final Map<String, String> times =
        fetchedGameTimes[int.parse(gameId)] ??
        {'timeHaste': 'N/A', 'timeNormal': 'N/A', 'timeComplete': 'N/A'};
    final String developer = fetchedDeveloperNames[int.parse(gameId)] ?? 'N/A';

    Game game = Game(
      id: gameId,
      name: name,
      thumbnailUrl: thumbnailUrl,
      artworkUrl: artworkUrl,
      rating: rating,
      releaseDate: releaseDate,
      developer: developer,
      genres: genres,
      overview: overview,
      timeHaste: times['timeHaste']!,
      timeNormal: times['timeNormal']!,
      timeComplete: times['timeComplete']!,
    );

    // Add game to cache list
    gamesToCacheEventually.add(game);

    // Add game to ready list
    readyGamesList.add(game);
  }

  // ----- Step 4: Cache all newly fetched games -----
  for (var game in gamesToCacheEventually) {
    await HiveHelper.insertGame(game);
  }

  return readyGamesList;
}

// ========== Batch Fetch Functions ========== //

Future<Map<int, String>> batchFetchCoverUrls(List<int> coverIds) async {
  if (coverIds.isEmpty) return {};

  // Initialize the map
  Map<int, String> results = {};

  // Filter out invalid IDs (0) for the API call
  final validCoverIds = coverIds.where((id) => id != 0).toList();

  // Only make an API call if there are valid IDs to fetch
  if (validCoverIds.isNotEmpty) {
    final query = '''
      fields id, image_id;
      where id = (${validCoverIds.join(',')});
      limit ${validCoverIds.length};
    ''';
    final response = await postRequest(gamesCoverArtUrl, query);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      for (var coverData in data) {
        if (coverData['id'] != null && coverData['image_id'] != null) {
          results[coverData['id'] as int] =
              'https://images.igdb.com/igdb/image/upload/t_cover_big/${coverData['image_id']}.webp';
        }
      }
    }
  }

  // Fill a default image for missing Ids
  for (var id in coverIds) {
    results.putIfAbsent(id, () => gamesMissingCoverUrl);
  }

  return results;
}

Future<Map<int, String>> batchFetchArtworkUrls(List<int> artworkIds) async {
  if (artworkIds.isEmpty) return {};

  // Initialize the map
  Map<int, String> results = {};

  // Filter out invalid IDs (0) for the API call
  final validArtworkIds = artworkIds.where((id) => id != 0).toList();

  // Only make an API call if there are valid IDs to fetch
  if (validArtworkIds.isNotEmpty) {
    final query = '''
    fields id, url;
    where id = (${validArtworkIds.join(',')});
    limit ${validArtworkIds.length};
  ''';

    final response = await postRequest(gamesArtworksUrl, query);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      for (var artData in data) {
        if (artData['id'] != null && artData['url'] != null) {
          results[artData['id']] =
              "https:${artData['url'].toString().replaceAll('t_thumb', 't_screenshot_huge')}";
        }
      }
    }
  }

  // Fill a default image for missing Ids
  for (var id in artworkIds) {
    results.putIfAbsent(id, () => gamesMissingArtworkUrl);
  }
  return results;
}

Future<Map<int, String>> batchFetchDeveloperNames(
  Map<int, List<int>> gameToInvolvedCompanyIdsMap,
) async {
  if (gameToInvolvedCompanyIdsMap.isEmpty) return {};

  // Initialize the map
  Map<int, String> gameDeveloperMap = {};

  // Get a list of unique ids
  List<int> allInvolvedCompanyIds =
      gameToInvolvedCompanyIdsMap.values.expand((ids) => ids).toSet().toList();

  // Return 'N/A' to all if there are no companies
  if (allInvolvedCompanyIds.isEmpty) {
    for (var gameId in gameToInvolvedCompanyIdsMap.keys) {
      gameDeveloperMap[gameId] = 'N/A';
    }
    return gameDeveloperMap;
  }

  // 1. Fetch company IDs from involved_company IDs
  final involvedQuery = '''
    fields id, company, developer; 
    where id = (${allInvolvedCompanyIds.join(',')}) & developer = true;
    limit ${allInvolvedCompanyIds.length};
  ''';
  final involvedResponse = await postRequest(
    gamesInvolvedCompaniesUrl,
    involvedQuery,
  );
  if (involvedResponse.statusCode != 200) {
    for (var gameId in gameToInvolvedCompanyIdsMap.keys) {
      gameDeveloperMap[gameId] = 'N/A';
    }
    return gameDeveloperMap;
  }

  final List<dynamic> involvedDataList = jsonDecode(involvedResponse.body);
  Map<int, int> involvedIdToCompanyIdMap = {};
  for (var involvedItem in involvedDataList) {
    if (involvedItem['id'] != null && involvedItem['company'] != null) {
      involvedIdToCompanyIdMap[involvedItem['id']] = involvedItem['company'];
    }
  }

  final List<int> companyIds = involvedIdToCompanyIdMap.values.toSet().toList();
  if (companyIds.isEmpty) {
    for (var gameId in gameToInvolvedCompanyIdsMap.keys) {
      gameDeveloperMap[gameId] = 'N/A';
    }
    return gameDeveloperMap;
  }

  // 2. Fetch company names from company IDs
  final companyQuery = '''
    fields id, name;
    where id = (${companyIds.join(',')});
    limit ${companyIds.length};
  ''';
  final companyResponse = await postRequest(gamesCompanyNamesUrl, companyQuery);
  if (companyResponse.statusCode != 200) {
    for (var gameId in gameToInvolvedCompanyIdsMap.keys) {
      gameDeveloperMap[gameId] = 'N/A';
    }
    return gameDeveloperMap;
  }

  final List<dynamic> companiesData = jsonDecode(companyResponse.body);
  Map<int, String> companyIdToNameMap = {}; // company.id -> company.name
  for (var companyItem in companiesData) {
    if (companyItem['id'] != null && companyItem['name'] != null) {
      companyIdToNameMap[companyItem['id']] = companyItem['name'];
    }
  }

  // 3. Map back to games
  gameToInvolvedCompanyIdsMap.forEach((gameId, invCompanyIds) {
    List<String> devNamesForGame = [];
    for (int invId in invCompanyIds) {
      int? compId = involvedIdToCompanyIdMap[invId];
      if (compId != null) {
        String? devName = companyIdToNameMap[compId];
        if (devName != null) {
          devNamesForGame.add(devName);
        }
      }
    }
    gameDeveloperMap[gameId] =
        devNamesForGame.isNotEmpty ? devNamesForGame.join(', ') : 'N/A';
  });

  return gameDeveloperMap;
}

Future<Map<int, Map<String, String>>> batchFetchGameTimes(
  List<int> gameIds,
) async {
  if (gameIds.isEmpty) return {};

  // Initialize the map
  Map<int, Map<String, String>> results = {};

  final query = '''
    fields game_id, hastily, normally, completely;
    where game_id = (${gameIds.join(',')});
    limit ${gameIds.length};
  ''';
  final response = await postRequest(gamesTimeUrl, query);

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    for (var timeData in data) {
      final int gameId = timeData['game_id'];
      results[gameId] = {
        'timeHaste':
            timeData['hastily'] != null
                ? (timeData['hastily'] / 3600).toStringAsFixed(1)
                : 'N/A',
        'timeNormal':
            timeData['normally'] != null
                ? (timeData['normally'] / 3600).toStringAsFixed(1)
                : 'N/A',
        'timeComplete':
            timeData['completely'] != null
                ? (timeData['completely'] / 3600).toStringAsFixed(1)
                : 'N/A',
      };
    }
  }

  // Ensure all gameIds have an entry, even if N/A
  for (var id in gameIds) {
    results.putIfAbsent(
      id,
      () => {'timeHaste': 'N/A', 'timeNormal': 'N/A', 'timeComplete': 'N/A'},
    );
  }

  return results;
}

// ========== Main Functions ==========

Future<Game?> getGameEntry(String inID) async {
  try {
    // 1. Fetch basic game info
    final query = '''
      fields $gamesCommonListFields; 
      where id = $inID;
      limit 1;
    ''';
    final gameResponse = await postRequest(gamesAPIUrl, query);
    if (gameResponse.statusCode != 200) {
      return null;
    }

    Map<String, dynamic> gameData = jsonDecode(gameResponse.body)[0];

    final int gameId = gameData['id'];
    final String name = gameData['name'];

    final String rating =
        gameData['rating'] != null
            ? (double.parse(gameData['rating'].toString()) / 10)
                .toStringAsFixed(1)
            : '0.0';

    final List<String> genres =
        (gameData['genres'] as List<dynamic>?)
            ?.map((g) => g['name'].toString())
            .toList() ??
        [];
    final String overview = gameData['summary'] ?? 'N/A';

    // Fetching individual pieces

    // Fetch thumbnail
    final int coverID = gameData['cover'] ?? 0;
    final String thumbnailUrl =
        (await batchFetchCoverUrls([coverID]))[coverID] ?? '';

    // Fetch release date
    final String releaseDate =
        gameData['first_release_date'] != null
            ? timestampToDate(gameData['first_release_date'])
            : 'N/A';

    // Fetch game times
    final Map<String, String> gameTimes =
        (await batchFetchGameTimes([gameId]))[gameId] ?? {};
    final String timeHaste = gameTimes['timeHaste'] ?? 'N/A';
    final String timeNormal = gameTimes['timeNormal'] ?? 'N/A';
    final String timeComplete = gameTimes['timeComplete'] ?? 'N/A';

    // Fetch developer
    String developer = 'N/A';
    if (gameData['involved_companies'] != null) {
      final List<int> involvedCompanyIds = List<int>.from(
        gameData['involved_companies'],
      );
      developer =
          (await batchFetchDeveloperNames({
            gameId: involvedCompanyIds,
          }))[gameId] ??
          'N/A';
    }

  // Fetch artwork
  int artworkID = gameData['artworks'] != null ? gameData['artworks'][0] : 0;
    final String artworkUrl =
        (await batchFetchArtworkUrls([artworkID]))[artworkID] ?? '';

    return Game(
      id: gameId.toString(),
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
    return null;
  }
}

Future<List<Game>> searchGamesByName(String name) async {
  final query = '''
  fields $gamesCommonListFields;
  search "$name";
  where rating_count > 10;
  limit 10;
''';

  final response = await postRequest(gamesAPIUrl, query);

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    return await processAndCacheGameList(data);
  } else {
    throw Exception("Failed to search games by name");
  }
}

Future<List<Game>> getFilteredGames(
  List<String> inGenresNames,
  String inCategoryId, // Changed from inCategory to inCategoryId
  String inMinRating,
) async {
  // Convert genre names to IDs
  List<String> inGenresIDs =
      inGenresNames
          .map((name) {
            final match = genresGames.firstWhere(
              (genre) => genre['name'] == name,
              orElse: () => {},
            );
            // Convert the ID to string, handle null case
            final id = match['id'];
            return id != null ? id.toString() : '';
          })
          .where(
            (id) => id.isNotEmpty,
          ) // Now this will work because id is a String
          .toList();

  String genreFilter = '';
  if (inGenresIDs.isNotEmpty) {
    genreFilter = 'genres = (${inGenresIDs.join(',')}) & ';
  }

  // Parse category ID directly since we're now passing the ID
  final categoryId = int.parse(inCategoryId);

  final query = '''
  fields $gamesCommonListFields;
  where ${genreFilter}category = $categoryId & rating >= ${(double.parse(inMinRating) * 10).toInt()} & rating_count > 10;
  sort rating desc;
  limit 60;
''';

  final response = await postRequest(gamesAPIUrl, query);

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    return await processAndCacheGameList(data);
  } else {
    throw Exception("Failed to fetch filtered games");
  }
}

Future<List<Game>> getDiscoverGames() async {
  // 1. Get popular game IDs
  final popularQuery = '''
    fields game_id, value;
    sort value desc;
    where popularity_type = 1;
    limit 10;
  ''';

  final popularResponse = await postRequest(gamesPopscoreUrl, popularQuery);
  if (popularResponse.statusCode != 200) {
    throw Exception('Failed to fetch popular game IDs');
  }

  final List<dynamic> popData = jsonDecode(popularResponse.body);
  final List<int> gameIds =
      popData.map((e) => e['game_id'] as int?).whereType<int>().toList();

  if (gameIds.isEmpty) return [];

  // 2. Fetch full game details for these IDs
  final gamesQuery = '''
    fields $gamesCommonListFields;
    where id = (${gameIds.join(',')});
    limit ${gameIds.length};
  ''';
  final gamesResponse = await postRequest(gamesAPIUrl, gamesQuery);
  if (gamesResponse.statusCode != 200) {
    throw Exception('Failed to fetch game data for popular games');
  }
  final List<dynamic> gamesData = jsonDecode(gamesResponse.body);
  return await processAndCacheGameList(gamesData);
}

Future<List<Game>> getComingSoonGames() async {
  // Get today's date
  final today = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;

  final query = '''
    fields $gamesCommonListFields;
    where first_release_date > $today & category = 0 & cover != null;
    sort first_release_date asc;
    limit 10;
  ''';
  final response = await postRequest(gamesAPIUrl, query);

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);

    return await processAndCacheGameList(data);
  } else {
    throw Exception('Failed to fetch upcoming games');
  }
}

Future<List<Game>> getRecentlyReleasedGames() async {
  // Get today's date
  final today = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;

  final query = '''
    fields $gamesCommonListFields;
    where first_release_date != null & first_release_date < $today & category = 0 & cover != null;
    sort first_release_date desc;
    limit 10;
  ''';
  final response = await postRequest(gamesAPIUrl, query);
  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    return await processAndCacheGameList(data);
  } else {
    throw Exception('Failed to fetch latest games');
  }
}

Future<List<Game>> getTopRatedGames({String limit = "10"}) async {
  final query = '''
    fields $gamesCommonListFields;
    where rating_count > 100 & category = 0 & cover != null;
    sort rating desc;
    limit $limit;
  ''';
  final response = await postRequest(gamesAPIUrl, query);
  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    return await processAndCacheGameList(data);
  } else {
    throw Exception("Failed to fetch top games");
  }
}

Future<List<List<Game>>> getCombinedGames() async {
  final today = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;

  final multiQuery = '''
query games "coming_soon" {
  fields $gamesCommonListFields;
  where first_release_date > $today & category = 0 & cover != null;
  sort first_release_date asc;
  limit 20;
};
query games "recently_released" {
  fields $gamesCommonListFields;
  where first_release_date != null & first_release_date < $today & category = 0 & cover != null;
  sort first_release_date desc;
  limit 20;
};
query games "top_rated" {
  fields $gamesCommonListFields;
  where rating_count > 100 & category = 0 & cover != null;
  sort rating desc;
  limit 20;
};
''';

  final response = await postRequest(
    "https://api.igdb.com/v4/multiquery",
    multiQuery,
  );
  if (response.statusCode != 200) {
    throw Exception('Failed to fetch combined games');
  }

  final List<dynamic> data = jsonDecode(response.body);

  // Extract ID lists for each query
  List<int> extractIds(String queryName) {
    final queryData = data.firstWhere(
      (q) => q['name'] == queryName,
      orElse: () => null,
    );
    if (queryData == null) return [];
    final List<dynamic> results = queryData['result'] ?? [];
    return results.map<int>((e) => e['id'] as int).toList();
  }

  final comingSoonIds = extractIds('coming_soon');
  final recentlyReleasedIds = extractIds('recently_released');
  final topRatedIds = extractIds('top_rated');

  // Combine all unique game data into one list
  final allGamesRaw = <dynamic>[];
  for (var qName in ['coming_soon', 'recently_released', 'top_rated']) {
    final qData = data.firstWhere(
      (q) => q['name'] == qName,
      orElse: () => null,
    );
    if (qData != null && qData['result'] != null) {
      allGamesRaw.addAll(qData['result']);
    }
  }

  // Remove duplicates by id
  final uniqueGamesMap = <int, dynamic>{};
  for (var game in allGamesRaw) {
    uniqueGamesMap[game['id']] = game;
  }

  final uniqueGamesList = uniqueGamesMap.values.toList();

  // Process and cache
  final allGamesProcessed = await processAndCacheGameList(uniqueGamesList);

  // Helper to get games by ID list, preserving order
  final mapById = {for (var g in allGamesProcessed) int.parse(g.id): g};

  List<Game> filterByIds(List<int> ids) {
    return ids
        .where((id) => mapById.containsKey(id))
        .map((id) => mapById[id]!)
        .toList();
  }

  final comingSoonGames = filterByIds(comingSoonIds);
  final recentlyReleasedGames = filterByIds(recentlyReleasedIds);
  final topRatedGames = filterByIds(topRatedIds);

  return [comingSoonGames, recentlyReleasedGames, topRatedGames];
}
