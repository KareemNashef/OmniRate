// Flutter imports
import 'package:hive_flutter/hive_flutter.dart';

// Local imports
import 'package:omnirate/API/igdb_api.dart';
import 'package:omnirate/API/tmdb_api.dart';
import 'package:omnirate/Database/model_game.dart';
import 'package:omnirate/Database/model_movie.dart';
import 'package:omnirate/Database/model_show.dart';

// ========== Main Functions ========== //

// getGame
// input: game name
// output: game object
// Searches the database for the game. if it is not found, look it up using the API
Future<Game?> getGame(String inName) async {
  // Search the database
  final game = await HiveHelper.getGameByName(inName);
  if (game != null) {
    return game;
  }

  // Look it up using the API
  Game? apiGame = await getGameEntry(inName);

  // Add the game to the database
  if (apiGame != null) {
    await HiveHelper.insertGame(apiGame);
    return apiGame;
  }

  return null;
}

// getShow
// input: show name
// output: show object
// Searches the database for the show. if it is not found, look it up using the API
Future<Show?> getShow(String inName) async {
  // 1. Check the local Hive database first
  final show = await HiveHelper.getShowByName(inName);
  if (show != null) {
    print("Found '${inName}' in cache.");
    return show;
  }

  // 2. If not found in cache, fetch from the API
  print("'${inName}' not in cache. Fetching from API...");
  final apiShow = await getShowEntry(inName);

  // 3. If the API call was successful, save the result to Hive
  if (apiShow != null) {
    print("Saving '${apiShow.name}' to cache.");
    await HiveHelper.insertShow(apiShow);
    return apiShow;
  }

  // 4. Return null if not found in cache or API
  return null;
}

// getMovie
// input: movie name
// output: movie object
// Searches the database for the movie. if it is not found, look it up using the API
Future<Movie?> getMovie(String inName) async {
  // 1. Check the local Hive database first
  final movie = await HiveHelper.getMovieByName(inName);
  if (movie != null) {
    print("Found '${inName}' in cache.");
    return movie;
  }

  // 2. If not found in cache, fetch from the API
  print("'${inName}' not in cache. Fetching from API...");
  final apiMovie = await getMovieEntry(inName);
  
  // 3. If the API call was successful, save the result to Hive
  if (apiMovie != null) {
    print("Saving '${apiMovie.name}' to cache.");
    await HiveHelper.insertMovie(apiMovie);
    return apiMovie;
  }

  // 4. Return null if not found in cache or API
  return null;
}

// ========== Hive Database Helper ========== //

class HiveHelper {
  // ===== Class variables =====

  // Box names
  static const String boxGames = 'games_box';
  static const String boxMovies = 'movies_box';
  static const String boxShows = 'shows_box';

  // ===== Initialization =====

  /// Initialize Hive database
  static Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(GameAdapter());
    Hive.registerAdapter(MovieAdapter());
    Hive.registerAdapter(ShowAdapter());

    // Open boxes
    await Hive.openBox<Game>(boxGames);
    await Hive.openBox<Movie>(boxMovies);
    await Hive.openBox<Show>(boxShows);
  }

  // Close all boxes
  static Future<void> close() async {
    await Hive.close();
  }

  // Clear all data (for testing or reset purposes)
  static Future<void> clearAllData() async {
    await Hive.box<Game>(boxGames).clear();
    await Hive.box<Movie>(boxMovies).clear();
    await Hive.box<Show>(boxShows).clear();
  }

  // ========== Game Methods ========== //

  // Insert a game into the database
  static Future<void> insertGame(Game game) async {
    final box = Hive.box<Game>(boxGames);
    await box.put(game.name.toLowerCase(), game);
  }

  // Get a game by its name
  static Future<Game?> getGameByName(String name) async {
    final box = Hive.box<Game>(boxGames);
    return box.get(name.toLowerCase());
  }

  // Update a game
  static Future<void> updateGame(Game game) async {
    await insertGame(game);
  }

  // ========== Show Methods ========== //

  // Insert a show into the database
  static Future<void> insertShow(Show show) async {
    final box = Hive.box<Show>(boxShows);
    await box.put(show.name.toLowerCase(), show);
  }

  // Get a show by its name
  static Future<Show?> getShowByName(String name) async {
    final box = Hive.box<Show>(boxShows);
    return box.get(name.toLowerCase());
  }

  // Update a show
  static Future<void> updateShow(Show show) async {
    await insertShow(show);
  }

  // ========== Movie Methods ========== //

  // Insert a movie into the database
  static Future<void> insertMovie(Movie movie) async {
    final box = Hive.box<Movie>(boxMovies);
    await box.put(movie.name.toLowerCase(), movie);
  }

  // Get a movie by its name
  static Future<Movie?> getMovieByName(String name) async {
    final box = Hive.box<Movie>(boxMovies);
    return box.get(name.toLowerCase());
  }

  // Update a movie
  static Future<void> updateMovie(Movie movie) async {
    await insertMovie(movie);
  }
}
