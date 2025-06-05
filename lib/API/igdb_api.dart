// ==================== IGDB API - Video Games ==================== //

// Flutter imports
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';

// Local imports
import 'package:omnirate/Database/model_game.dart';
import 'package:omnirate/Database/database_helper.dart';
import 'package:omnirate/Shared/utils.dart';

// ========== Helper Consts ========== //

// API Keys
final igdbHeaders = {
  'Client-ID': 'uy1ewiwcafvxgao5jq3bxhme0z20tx',
  'Authorization': 'Bearer 2bf4mjgv69yeh7buax0ijizt6bsg5u',
  'Accept': 'application/json',
};

// API URLs
const String gamesUrl = 'https://api.igdb.com/v4/games';
const String releaseDateUrl = 'https://api.igdb.com/v4/release_dates';
const String coverArtUrl = 'https://api.igdb.com/v4/covers';
const String gameTimeUrl = 'https://api.igdb.com/v4/game_time_to_beats';
const String involvedCompaniesUrl =
    'https://api.igdb.com/v4/involved_companies';
const String companyNamesUrl = 'https://api.igdb.com/v4/companies';
const String artworksUrl = 'https://api.igdb.com/v4/artworks';
const String popscoreUrl = 'https://api.igdb.com/v4/popularity_primitives';

// Common fields for list queries
const String _commonGameListFields =
    'id, name, cover, rating, first_release_date, genres.name, summary, involved_companies, artworks';

// Missing media URLs
const String missingCoverUrl =
    'https://www.igdb.com/assets/no_cover_show-ef1e36c00e101c2fb23d15bb80edd9667bbf604a12fc0267a66033afea320c65.png';
const String missingArtworkUrl =
    'https://img.freepik.com/free-vector/futuristic-video-game-controller-background-with-text-space_1017-54730.jpg';

// ========== Eager Future Class ========== //

class EagerFuture<T> implements Future<T> {
  final Future<T> _future;
  late T _result;
  Object? _error;
  bool _isCompleted = false;
  bool _hasError = false;

  EagerFuture(Future<T> future) : _future = future {
    _future
        .then((value) {
          _result = value;
          _isCompleted = true;
        })
        .catchError((error, stackTrace) {
          _error = error;
          _isCompleted = true;
          _hasError = true;
          // Optionally rethrow or handle:
          // Completer().completeError(error, stackTrace);
        });
  }

  @override
  Stream<T> asStream() => _future.asStream();

  @override
  Future<T> catchError(Function onError, {bool Function(Object error)? test}) =>
      _future.catchError(onError, test: test);

  @override
  Future<R> then<R>(
    FutureOr<R> Function(T value) onValue, {
    Function? onError,
  }) {
    if (_isCompleted && !_hasError) {
      try {
        return Future.value(onValue(_result));
      } catch (e, s) {
        if (onError != null) {
          // Simulating Future's onError behavior
          try {
            return Future.value(onError(e, s));
          } catch (ne, ns) {
            return Future.error(ne, ns);
          }
        }
        return Future.error(e, s);
      }
    } else if (_isCompleted && _hasError) {
      if (onError != null) {
        try {
          return Future.value(
            onError(
              _error!,
              StackTrace.current /*or store original if possible*/,
            ),
          );
        } catch (e, s) {
          return Future.error(e, s);
        }
      }
      return Future.error(_error!);
    }
    return _future.then(onValue, onError: onError);
  }

  @override
  Future<T> timeout(Duration timeLimit, {FutureOr<T> Function()? onTimeout}) =>
      _future.timeout(timeLimit, onTimeout: onTimeout);

  @override
  Future<T> whenComplete(FutureOr<void> Function() action) =>
      _future.whenComplete(action);
}

// ========== Rate Limiting Class ========== //

class RateLimiter {
  static const int maxRequestsPerSecond = 4;
  static final List<DateTime> _requestTimes = [];

  static Future<void> waitForRateLimit() async {
    final now = DateTime.now();

    // Remove requests older than 1 second
    _requestTimes.removeWhere(
      (time) => now.difference(time).inMilliseconds > 1000,
    );

    // If we've made 4 requests in the last second, wait
    if (_requestTimes.length >= maxRequestsPerSecond) {
      final oldestRequest = _requestTimes.first;
      final waitTime = 1000 - now.difference(oldestRequest).inMilliseconds;
      if (waitTime > 0) {
        await Future.delayed(Duration(milliseconds: waitTime));
      }
    }

    _requestTimes.add(DateTime.now());
  }
}

// ========== Helper Functions ========== //

// Post request handler
Future<http.Response> postRequest(String inURL, String inQuery) async {
  // Wait for rate limit
  await RateLimiter.waitForRateLimit();

  // Send the request
  return await http.post(Uri.parse(inURL), headers: igdbHeaders, body: inQuery);
}

// Convert Unix timestamp to "YYYY-MM-DD" or "N/A"
String _formatTimestampToDate(int? timestamp) {
  if (timestamp == null) return 'N/A';
  final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
  return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
}

// Process and cache game list
Future<List<Game>> _processAndCacheGameList(
  List<dynamic> rawGamesData,
) async {
  // Initialize list
  List<Game> readyGamesList = [];
  if (rawGamesData.isEmpty) return readyGamesList;

  // Initialize lists
  List<Game> gamesToCacheEventually = []; // Games fetched from API to be cached
  List<dynamic> gamesToProcessFromApi = []; // Raw game data for games NOT found in cache

  // Step 1: Check if game is in cache
  for (var rawGameData in rawGamesData) {
    final String? name = rawGameData['name'] as String?;
    if (name == null || name == 'N/A') {
      continue;
    }

    Game? existingGame = await HiveHelper.getGameByName(name);
    if (existingGame != null) {
      // Game found in cache, use its data directly
      readyGamesList.add(existingGame);
    } else {
      // Game not in cache, add its raw data to the list for API processing
      if (rawGameData['id'] != null) {
        // Ensure it has an ID for further processing
        gamesToProcessFromApi.add(rawGameData);
      } else {}
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
    _batchFetchCoverUrls(coverIdsToFetch),
  );
  final EagerFuture<Map<int, String>> artworkUrlsFuture = EagerFuture(
    _batchFetchArtworkUrls(artworkIdsToFetch),
  );
  final EagerFuture<Map<int, Map<String, String>>> gameTimesFuture =
      EagerFuture(_batchFetchGameTimes(gameIdsToFetch));
  final EagerFuture<Map<int, String>> developerNamesFuture = EagerFuture(
    _batchFetchDeveloperNames(gameToInvolvedCompanyIdsMapForFetching),
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
    // Iterate ONLY over games we processed via API
    final int gameId = gameData['id'];
    final String name =
        gameData['name'] ?? 'N/A'; // Should be valid due to earlier check

    // Data from initial fetch (gamesToProcessFromApi contains this)
    final double rating =
        gameData['rating'] != null
            ? double.parse(
              (double.parse(gameData['rating'].toString()) / 10)
                  .toStringAsFixed(1),
            )
            : 0.0;
    final List<String> genres =
        (gameData['genres'] as List<dynamic>?)
            ?.map((g) => g['name'].toString())
            .toList() ??
        [];
    final String overview = gameData['summary'] ?? 'N/A';
    final String releaseDate = _formatTimestampToDate(
      gameData['first_release_date'],
    );

    // Data from batch fetches
    final String thumbnailUrl =
        fetchedCoverUrls[gameData['cover'] ?? 0] ?? missingCoverUrl;
    final String artworkUrl =
        fetchedArtworkUrls[(gameData['artworks'] != null &&
                gameData['artworks'].isNotEmpty
            ? gameData['artworks'][0]
            : 0)] ??
        'N/A';

    final Map<String, String> times =
        fetchedGameTimes[gameId] ??
        {'timeHaste': 'N/A', 'timeNormal': 'N/A', 'timeComplete': 'N/A'};
    final String developer = fetchedDeveloperNames[gameId] ?? 'N/A';

    Game game = Game(
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

// Fetches cover art URLs for a list of cover IDs
Future<Map<int, String>> _batchFetchCoverUrls(List<int> coverIds) async {
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
    final response = await postRequest(coverArtUrl, query);

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
    results.putIfAbsent(id, () => missingCoverUrl);
  }

  return results;
}

// Fetch artworks URLs for a list of artwork IDs
Future<Map<int, String>> _batchFetchArtworkUrls(List<int> artworkIds) async {
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

    final response = await postRequest(artworksUrl, query);

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
    results.putIfAbsent(id, () => missingArtworkUrl);
  }
  return results;
}

// Fetch multiple company names
Future<Map<int, String>> _batchFetchDeveloperNames(
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
    involvedCompaniesUrl,
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
  final companyResponse = await postRequest(companyNamesUrl, companyQuery);
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

// Fetch multiple game times
Future<Map<int, Map<String, String>>> _batchFetchGameTimes(
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
  final response = await postRequest(gameTimeUrl, query);

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

Future<Game?> getGameEntry(String inName) async {
  try {
    // 1. Fetch basic game info
    final query = '''
      fields $_commonGameListFields; 
      search "$inName";
      where category = 0;
      limit 1; 
    ''';
    final gameResponse = await postRequest(gamesUrl, query);
    if (gameResponse.statusCode != 200) {
      throw Exception(
        "Game fetch failed: ${gameResponse.statusCode} ${gameResponse.body}",
      );
    }
    final gameList = jsonDecode(gameResponse.body);
    Map<String, dynamic> gameData = {};
    if (gameList.isEmpty) {
      final exactNameQuery = '''
            fields $_commonGameListFields;
            where name = "$inName" & category = (0,8,9);
            limit 1;
        ''';
      final exactResponse = await postRequest(gamesUrl, exactNameQuery);
      if (exactResponse.statusCode == 200) {
        final exactGameList = jsonDecode(exactResponse.body);
        if (exactGameList.isEmpty) return null;
        gameData = exactGameList[0];
      } else {
        return null;
      }
    } else {
      gameData = gameList[0];
    }

    final int gameId = gameData['id'];
    final String name = gameData['name'];

    final double rating =
        gameData['rating'] != null
            ? double.parse(
              (double.parse(gameData['rating'].toString()) / 10)
                  .toStringAsFixed(1),
            )
            : 0.0;
    final List<String> genres =
        (gameData['genres'] as List<dynamic>?)
            ?.map((g) => g['name'].toString())
            .toList() ??
        [];
    final String overview = gameData['summary'] ?? 'N/A';

    // Fetching individual pieces

    // Fetch thumbnail
    final String thumbnailUrl =
        (await _batchFetchCoverUrls([gameId]))[gameId] ?? '';

    // Fetch release date
    final String releaseDate =
        gameData['first_release_date'] != null
            ? _formatTimestampToDate(gameData['first_release_date'])
            : 'N/A';

    // Fetch game times
    final Map<String, String> gameTimes =
        (await _batchFetchGameTimes([gameId]))[gameId] ?? {};
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
          (await _batchFetchDeveloperNames({
            gameId: involvedCompanyIds,
          }))[gameId] ??
          'N/A';
    }

    final String artworkUrl =
        (await _batchFetchArtworkUrls([gameId]))[gameId] ?? '';

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
    return null;
  }
}

Future<List<Game>> searchGamesByName(String name) async {
  final query = '''
  fields $_commonGameListFields;
  search "$name";
  where rating_count > 10;
  limit 10;
''';

  final response = await postRequest(gamesUrl, query);

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    return await _processAndCacheGameList(data);
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
  fields $_commonGameListFields;
  where ${genreFilter}category = $categoryId & rating >= ${(double.parse(inMinRating) * 10).toInt()} & rating_count > 10;
  sort rating desc;
  limit 60;
''';

  final response = await postRequest(gamesUrl, query);

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    return await _processAndCacheGameList(data);
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

  final popularResponse = await postRequest(popscoreUrl, popularQuery);
  if (popularResponse.statusCode != 200) {
    throw Exception('Failed to fetch popular game IDs');
  }

  final List<dynamic> popData = jsonDecode(popularResponse.body);
  final List<int> gameIds =
      popData.map((e) => e['game_id'] as int?).whereType<int>().toList();

  if (gameIds.isEmpty) return [];

  // 2. Fetch full game details for these IDs
  final gamesQuery = '''
    fields $_commonGameListFields;
    where id = (${gameIds.join(',')});
    limit ${gameIds.length};
  ''';
  final gamesResponse = await postRequest(gamesUrl, gamesQuery);
  if (gamesResponse.statusCode != 200) {
    throw Exception('Failed to fetch game data for popular games');
  }
  final List<dynamic> gamesData = jsonDecode(gamesResponse.body);
  return await _processAndCacheGameList(gamesData);
}

Future<List<Game>> getComingSoonGames() async {
  // Get today's date
  final today = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;

  final query = '''
    fields $_commonGameListFields;
    where first_release_date > $today & category = 0 & cover != null;
    sort first_release_date asc;
    limit 10;
  ''';
  final response = await postRequest(gamesUrl, query);

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    return await _processAndCacheGameList(data);
  } else {
    throw Exception('Failed to fetch upcoming games');
  }
}

Future<List<Game>> getRecentlyReleasedGames() async {
  // Get today's date
  final today = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;

  final query = '''
    fields $_commonGameListFields;
    where first_release_date != null & first_release_date < $today & category = 0 & cover != null;
    sort first_release_date desc;
    limit 10;
  ''';
  final response = await postRequest(gamesUrl, query);
  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    return await _processAndCacheGameList(data);
  } else {
    throw Exception('Failed to fetch latest games');
  }
}

Future<List<Game>> getTopRatedGames({String limit = "10"}) async {
  final query = '''
    fields $_commonGameListFields;
    where rating_count > 100 & category = 0 & cover != null;
    sort rating desc;
    limit $limit;
  ''';
  final response = await postRequest(gamesUrl, query);
  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    return await _processAndCacheGameList(data);
  } else {
    throw Exception("Failed to fetch top games");
  }
}
