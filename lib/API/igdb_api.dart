// ==================== IGDB API - Video Games ==================== //

// Flutter imports
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';

// Local imports
import 'package:omnirate/Database/model_game.dart';
import 'package:omnirate/Database/database_helper.dart';
import 'package:omnirate/Shared/firebase_service.dart';
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
  final stopwatch = Stopwatch()..start();

  if (rawGamesData.isEmpty) {
    stopwatch.stop();
    return [];
  }

  // Final list of games to be returned
  List<Game> readyGamesList = [];
  // Games found in Firebase or fetched from API that need to be saved to local Hive cache
  List<Game> gamesToCacheInHive = [];

  // Create a map of the raw data for easy lookup by ID later
  final Map<int, dynamic> rawGamesMap = {
    for (var g in rawGamesData)
      if (g['id'] != null) g['id']: g,
  };
  final allGameIds = rawGamesMap.keys.map((id) => id.toString()).toList();

  // ----- Step 1: Batch check local Hive cache -----
  final Map<String, Game> hiveCacheHits = await HiveHelper.getGamesByIDs(
    allGameIds,
  );
  readyGamesList.addAll(hiveCacheHits.values);

  final idsNotInHive =
      allGameIds.where((id) => !hiveCacheHits.containsKey(id)).toList();

  // If all games were in the local cache, we are done.
  if (idsNotInHive.isEmpty) {
    stopwatch.stop();
    // The list is already sorted by the original API response order, so we need to re-sort it.
    return readyGamesList..sort(
      (a, b) => allGameIds.indexOf(a.id).compareTo(allGameIds.indexOf(b.id)),
    );
  }

  // ----- Step 2: Batch check Firebase (cloud) cache -----
  final firebaseService = FirebaseService();
  final Map<String, Game> firebaseCacheHits = await firebaseService
      .loadMultipleGames(idsNotInHive);

  readyGamesList.addAll(firebaseCacheHits.values);
  gamesToCacheInHive.addAll(
    firebaseCacheHits.values,
  ); // Queue these to be saved in Hive later

  final idsToFetchFromApi =
      idsNotInHive.where((id) => !firebaseCacheHits.containsKey(id)).toList();

  // If all remaining games were found in Firebase, we just need to cache them and return.
  if (idsToFetchFromApi.isEmpty) {
    if (gamesToCacheInHive.isNotEmpty) {
      await HiveHelper.insertAllGames(gamesToCacheInHive);
    }
    stopwatch.stop();
    return readyGamesList..sort(
      (a, b) => allGameIds.indexOf(a.id).compareTo(allGameIds.indexOf(b.id)),
    );
  }

  // ----- Step 3: Prepare and Batch fetch remaining games from IGDB API -----
  final List<dynamic> gamesToProcessFromApi =
      idsToFetchFromApi.map((id) => rawGamesMap[int.parse(id)]!).toList();

  // Prepare all the necessary ID lists for batch fetching
  List<int> gameIdsToFetch =
      gamesToProcessFromApi.map<int>((g) => g['id'] as int).toList();
  List<int> coverIdsToFetch =
      gamesToProcessFromApi.map<int>((g) => (g['cover'] ?? 0) as int).toList();
  List<int> artworkIdsToFetch =
      gamesToProcessFromApi
          .map<int>(
            (g) =>
                (g['artworks'] != null && g['artworks'].isNotEmpty
                        ? g['artworks'][0]
                        : 0)
                    as int,
          )
          .toList();
  Map<int, List<int>> gameToInvolvedCompanyIdsMapForFetching = {
    for (var gameData in gamesToProcessFromApi)
      gameData['id'] as int: List<int>.from(
        gameData['involved_companies'] ?? [],
      ),
  };

  // Perform all API fetches concurrently
  final results = await Future.wait([
    batchFetchCoverUrls(coverIdsToFetch),
    batchFetchArtworkUrls(artworkIdsToFetch),
    batchFetchGameTimes(gameIdsToFetch),
    batchFetchDeveloperNames(gameToInvolvedCompanyIdsMapForFetching),
  ]);

  final Map<int, String> fetchedCoverUrls = results[0] as Map<int, String>;
  final Map<int, String> fetchedArtworkUrls = results[1] as Map<int, String>;
  final Map<int, Map<String, String>> fetchedGameTimes =
      results[2] as Map<int, Map<String, String>>;
  final Map<int, String> fetchedDeveloperNames = results[3] as Map<int, String>;

  // ----- Step 4: Construct Game objects and save to Firebase -----
  List<Game> newlyFetchedGames = [];
  List<Future> firebaseSaveFutures = [];

  for (var gameData in gamesToProcessFromApi) {
    final gameId = gameData['id'];
    final times =
        fetchedGameTimes[gameId] ??
        {'timeHaste': 'N/A', 'timeNormal': 'N/A', 'timeComplete': 'N/A'};

    Game game = Game(
      id: gameId.toString(),
      name: gameData['name'] ?? 'N/A',
      thumbnailUrl:
          fetchedCoverUrls[gameData['cover'] ?? 0] ?? gamesMissingCoverUrl,
      artworkUrl:
          fetchedArtworkUrls[(gameData['artworks'] != null &&
                  gameData['artworks'].isNotEmpty
              ? gameData['artworks'][0]
              : 0)] ??
          'N/A',
      rating:
          gameData['rating'] != null
              ? (double.parse(gameData['rating'].toString()) / 10)
                  .toStringAsFixed(1)
              : '0.0',
      releaseDate: timestampToDate(gameData['first_release_date']),
      developer: fetchedDeveloperNames[gameId] ?? 'N/A',
      genres:
          (gameData['genres'] as List<dynamic>?)
              ?.map((g) => g['name'].toString())
              .toList() ??
          [],
      overview: gameData['summary'] ?? 'N/A',
      timeHaste: times['timeHaste']!,
      timeNormal: times['timeNormal']!,
      timeComplete: times['timeComplete']!,
      expansions:
          (gameData['expansions'] as List<dynamic>?)
              ?.map((g) => g.toString())
              .toList() ??
          [],
      dlcs:
          (gameData['dlcs'] as List<dynamic>?)
              ?.map((g) => g.toString())
              .toList() ??
          [],
      similarGames:
          (gameData['similar_games'] as List<dynamic>?)
              ?.map((g) => g.toString())
              .toList() ??
          [],
    );

    newlyFetchedGames.add(game);
    // Add the save operation to a list of futures to run them concurrently
    firebaseSaveFutures.add(firebaseService.saveEntry(game));
  }

  // Wait for all Firebase saves to complete
  await Future.wait(firebaseSaveFutures);

  readyGamesList.addAll(newlyFetchedGames);
  gamesToCacheInHive.addAll(newlyFetchedGames);

  // ----- Step 5: Batch write all new games to local Hive cache -----
  if (gamesToCacheInHive.isNotEmpty) {
    await HiveHelper.insertAllGames(gamesToCacheInHive);
  }

  stopwatch.stop();

  // Re-sort the final list to match the original order from the initial API call
  return readyGamesList..sort(
    (a, b) => allGameIds.indexOf(a.id).compareTo(allGameIds.indexOf(b.id)),
  );
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

  Map<int, String> gameDeveloperMap = {};
  // Initialize all games with 'N/A' to handle cases where no developer is found
  for (var gameId in gameToInvolvedCompanyIdsMap.keys) {
    gameDeveloperMap[gameId] = 'N/A';
  }

  List<int> allInvolvedCompanyIds =
      gameToInvolvedCompanyIdsMap.values.expand((ids) => ids).toSet().toList();

  if (allInvolvedCompanyIds.isEmpty) {
    return gameDeveloperMap; // Already initialized to 'N/A'
  }

  // 1. Fetch involved company info AND the company name in a single call.
  // We expand the 'company' field to get its 'name'.
  final query = '''
    fields game, company.name; 
    where id = (${allInvolvedCompanyIds.join(',')}) & developer = true;
    limit ${allInvolvedCompanyIds.length};
  ''';

  final response = await postRequest(gamesInvolvedCompaniesUrl, query);
  if (response.statusCode != 200) {
    return gameDeveloperMap; // Return the map with 'N/A' values
  }

  final List<dynamic> involvedDataList = jsonDecode(response.body);

  // 2. Build a map of Game ID -> List of Developer Names
  Map<int, List<String>> tempGameToDevsMap = {};
  for (var involvedItem in involvedDataList) {
    // Ensure the required fields exist and are not null
    if (involvedItem['game'] != null &&
        involvedItem['company'] != null &&
        involvedItem['company']['name'] != null) {
      final int gameId = involvedItem['game'];
      final String devName = involvedItem['company']['name'];

      // Initialize the list if it doesn't exist for this gameId
      tempGameToDevsMap.putIfAbsent(gameId, () => []);
      tempGameToDevsMap[gameId]!.add(devName);
    }
  }

  // 3. Join the developer names for each game and update the final map.
  tempGameToDevsMap.forEach((gameId, devNames) {
    if (devNames.isNotEmpty) {
      gameDeveloperMap[gameId] = devNames.join(', ');
    }
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
    // 1. Fetch the main game data first, as it contains IDs for other fetches.
    final query = '''
      fields $gamesCommonListFields; 
      where id = $inID;
      limit 1;
    ''';
    final gameResponse = await postRequest(gamesAPIUrl, query);
    if (gameResponse.statusCode != 200 || gameResponse.body == '[]') {
      return null;
    }

    final gameData = jsonDecode(gameResponse.body)[0];

    // 2. Extract all necessary IDs and basic data from the first response.
    final int gameId = gameData['id'];
    final String name = gameData['name'] ?? 'N/A';
    final String overview = gameData['summary'] ?? 'N/A';
    final String releaseDate = timestampToDate(gameData['first_release_date']);
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

    final int coverID = gameData['cover'] ?? 0;
    final int artworkID =
        (gameData['artworks'] != null && gameData['artworks'].isNotEmpty)
            ? gameData['artworks'][0]
            : 0;
    final List<int> involvedCompanyIds =
        gameData['involved_companies'] != null
            ? List<int>.from(gameData['involved_companies'])
            : [];

    final expansions = List<String>.from(
      gameData['expansions']?.map((e) => e.toString()) ?? [],
    );
    final dlcs = List<String>.from(
      gameData['dlcs']?.map((e) => e.toString()) ?? [],
    );
    final similarGames = List<String>.from(
      gameData['similar_games']?.map((e) => e.toString()) ?? [],
    );

    // 3. Create a list of all futures to run in parallel.
    final futures = [
      batchFetchCoverUrls([coverID]),
      batchFetchArtworkUrls([artworkID]),
      batchFetchGameTimes([gameId]),
      if (involvedCompanyIds.isNotEmpty)
        batchFetchDeveloperNames({gameId: involvedCompanyIds}),
    ];

    // 4. Await all of them concurrently.
    final results = await Future.wait(futures);

    // 5. Process the results.
    final Map<int, String> coverUrls = results[0] as Map<int, String>;
    final Map<int, String> artworkUrls = results[1] as Map<int, String>;
    final Map<int, Map<String, String>> gameTimesMap =
        results[2] as Map<int, Map<String, String>>;

    String developer = 'N/A';
    if (involvedCompanyIds.isNotEmpty) {
      final Map<int, String> developerNames = results[3] as Map<int, String>;
      developer = developerNames[gameId] ?? 'N/A';
    }

    final String thumbnailUrl = coverUrls[coverID] ?? gamesMissingCoverUrl;
    final String artworkUrl = artworkUrls[artworkID] ?? gamesMissingArtworkUrl;
    final Map<String, String> gameTimes =
        gameTimesMap[gameId] ??
        {'timeHaste': 'N/A', 'timeNormal': 'N/A', 'timeComplete': 'N/A'};

    // 6. Construct and return the Game object.
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
      timeHaste: gameTimes['timeHaste']!,
      timeNormal: gameTimes['timeNormal']!,
      timeComplete: gameTimes['timeComplete']!,
      expansions: expansions,
      dlcs: dlcs,
      similarGames: similarGames,
    );
  } catch (e) {
    // Add logging here to see what fails
    return null;
  }
}

Future<List<Game>> searchGamesByName(String name) async {
  final query = '''
  fields $gamesCommonListFields;
  search "$name";
  where rating_count > 10;
  limit 30;
''';

  final response = await postRequest(gamesAPIUrl, query);

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    return await processAndCacheGameList(data);
  } else {
    throw Exception("Failed to search games by name");
  }
}

Future<List<Game>> getGamesByIDs(List<String> gameIDs) async {
 // Empty check
  if (gameIDs.isEmpty) {
    return [];
  }

  final query = '''
  fields $gamesCommonListFields;
  where id = (${gameIDs.join(',')});
  limit ${gameIDs.length};
''';

  final response = await postRequest(gamesAPIUrl, query);
  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    return await processAndCacheGameList(data);
  } else {
    throw Exception("Failed to fetch games by IDs");
  }
}

Future<List<Game>> getFilteredGames(
  List<String> inGenresNames,
  String inCategoryId,
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
