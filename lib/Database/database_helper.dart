// Flutter imports
import 'package:hive_flutter/hive_flutter.dart';

// Local imports
import 'package:omnirate/Database/model_game.dart';
import 'package:omnirate/Database/model_movie.dart';
import 'package:omnirate/Database/model_show.dart';

// ========== Main Functions ========== //

// getGame
// input: game name
// output: game object
// Searches the database for the game. if it is not found, look it up using the API
Future<Game?> getGame(String inName) async {
  final game = await HiveHelper.getGameByName(inName);
  if (game != null) {
    return game;
  }

  // TODO: Add API call here to fetch game data
  // Game? apiGame = await fetchGameFromAPI(inName);
  // if (apiGame != null) {
  //   await HiveHelper.insertGame(apiGame);
  //   return apiGame;
  // }

  return null;
}

// getShow
// input: show name
// output: show object
// Searches the database for the show. if it is not found, look it up using the API
Future<Show?> getShow(String inName) async {
  final show = await HiveHelper.getShowByName(inName);
  if (show != null) {
    return show;
  }

  // TODO: Add API call here to fetch show data
  // Show? apiShow = await fetchShowFromAPI(inName);
  // if (apiShow != null) {
  //   await HiveHelper.insertShow(apiShow);
  //   return apiShow;
  // }

  return null;
}

// getMovie
// input: movie name
// output: movie object
// Searches the database for the movie. if it is not found, look it up using the API
Future<Movie?> getMovie(String inName) async {
  final movie = await HiveHelper.getMovieByName(inName);
  if (movie != null) {
    return movie;
  }

  // TODO: Add API call here to fetch movie data
  // Movie? apiMovie = await fetchMovieFromAPI(inName);
  // if (apiMovie != null) {
  //   await HiveHelper.insertMovie(apiMovie);
  //   return apiMovie;
  // }

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
