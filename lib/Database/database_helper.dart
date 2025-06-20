// ==================== Database Helper ==================== //

// Flutter imports
import 'package:hive_flutter/hive_flutter.dart';

// Local imports
import 'package:omnirate/API/igdb_api.dart';
import 'package:omnirate/API/tmdb_api.dart';
import 'package:omnirate/Database/model_game.dart';
import 'package:omnirate/Database/model_movie.dart';
import 'package:omnirate/Database/model_show.dart';
import 'package:omnirate/Shared/firebase_service.dart';

// ========== Main Functions ========== //

Future<Game?> getGame(String inID, {bool forceUpdate = false}) async {
  final firebaseService = FirebaseService();
  if (forceUpdate == false) {
    // Look it up in the Hive database
    final local = await HiveHelper.getGameByID(inID);
    if (local != null) return local;

    // Look it up in the cloud database
    final cloud =
        await firebaseService.loadEntry("MediaType.game", inID) as Game?;
    if (cloud != null) {
      await HiveHelper.insertGame(cloud);
      return cloud;
    }
  }

  // Look it up using the API
  final apiGame = await getGameEntry(inID);
  if (apiGame != null) {
    await HiveHelper.insertGame(apiGame);
    await firebaseService.saveEntry(apiGame);
    return apiGame;
  }

  return null;
}

Future<Show?> getShow(String inID, {bool forceUpdate = false}) async {
  final firebaseService = FirebaseService();
  if (forceUpdate == false) {
    // Look it up in the Hive database
    final local = await HiveHelper.getShowByID(inID);
    if (local != null) return local;

    // Look it up in the cloud database
    final cloud =
        await firebaseService.loadEntry("MediaType.show", inID) as Show?;
    if (cloud != null) {
      await HiveHelper.insertShow(cloud);
      return cloud;
    }
  }
  // Look it up using the API
  final apiShow = await getShowEntry(inID);
  if (apiShow != null) {
    await HiveHelper.insertShow(apiShow);
    await firebaseService.saveEntry(apiShow);
    return apiShow;
  }

  return null;
}

Future<Movie?> getMovie(String inID, {bool forceUpdate = false}) async {
  final firebaseService = FirebaseService();
  if (forceUpdate == false) {
    // Look it up in the Hive database
    final local = await HiveHelper.getMovieByID(inID);
    if (local != null) return local;

    // Look it up in the cloud database
    final cloud =
        await firebaseService.loadEntry("MediaType.movie", inID) as Movie?;
    if (cloud != null) {
      await HiveHelper.insertMovie(cloud);
      return cloud;
    }
  }
  // Look it up using the API
  final apiMovie = await getMovieEntry(inID);
  if (apiMovie != null) {
    await HiveHelper.insertMovie(apiMovie);
    await firebaseService.saveEntry(apiMovie);
    return apiMovie;
  }

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

  // Initialize Hive database
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

  static Future<Set<String>> getAllIDs() async {
    final gameIDs = Hive.box<Game>(boxGames).keys.cast<String>();
    final movieIDs = Hive.box<Movie>(boxMovies).keys.cast<String>();
    final showIDs = Hive.box<Show>(boxShows).keys.cast<String>();
    return {...gameIDs, ...movieIDs, ...showIDs};
  }

  // ========== Game Methods ========== //

  // Insert a game into the database
  static Future<void> insertGame(Game game) async {
    final box = Hive.box<Game>(boxGames);
    await box.put(game.id, game);
  }

  // Get a game by its name
  static Future<Game?> getGameByID(String id) async {
    final box = Hive.box<Game>(boxGames);
    return box.get(id);
  }

  // Update a game
  static Future<void> updateGame(Game game) async {
    await insertGame(game);
  }

  // ========== Show Methods ========== //

  // Insert a show into the database
  static Future<void> insertShow(Show show) async {
    final box = Hive.box<Show>(boxShows);
    await box.put(show.id, show);
  }

  // Get a show by its name
  static Future<Show?> getShowByID(String id) async {
    final box = Hive.box<Show>(boxShows);
    return box.get(id);
  }

  // Update a show
  static Future<void> updateShow(Show show) async {
    await insertShow(show);
  }

  // ========== Movie Methods ========== //

  // Insert a movie into the database
  static Future<void> insertMovie(Movie movie) async {
    final box = Hive.box<Movie>(boxMovies);
    await box.put(movie.id, movie);
  }

  // Get a movie by its name
  static Future<Movie?> getMovieByID(String id) async {
    final box = Hive.box<Movie>(boxMovies);
    return box.get(id);
  }

  // Update a movie
  static Future<void> updateMovie(Movie movie) async {
    await insertMovie(movie);
  }
}
