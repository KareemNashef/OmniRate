// Flutter imports
import 'package:sqflite/sqflite.dart';

// Local imports
import 'package:omnirate/Database/model_game.dart';
import 'package:omnirate/Database/model_movie.dart';
import 'package:omnirate/Database/model_show.dart';

// ========== Main Functions ========== //

// getGame
// input: game name
// output: game object
// Searches the database for the game. if it is not found, look it up using the API
Game getGame(String inName) {}

// getShow
// input: show name
// output: show object
// Searches the database for the show. if it is not found, look it up using the API
Show getShow(String inName) {}

// getMovie
// input: movie name
// output: movie object
// Searches the database for the movie. if it is not found, look it up using the API
Movie getMovie(String inName) {}

// ========== Database helper ========== //

class DatabaseHelper {

  // ===== Class variables =====

  // Database instance
  static Database? _database;

  // Table names
  static const String tableGames = 'games';
  static const String tableMovies = 'movies';
  static const String tableShows = 'shows';

  // ===== Class methods =====

  // Singleton pattern to get the database instance
  // ...

  // ========== Game Methods ========== //

  // Insert a game into the database
  static Future<void> insertGame(Game inGame) {}

  // Get a game by its name
  static Future<Game?> getGameByName(String inName) {}

  // Update a game
  static Future<int> updateGame(Game inGame) {}

  // ========== Show Methods ========== //

  // Insert a show into the database
  static Future<void> insertShow(Show show) {}

  // Get a show by its name
  static Future<Show?> getShowByName(String inName) {}

  // Update a show
  static Future<int> updateShow(Show inMovie) {}
  
  // ========== Movie Methods ========== //

  // Insert a movie into the database
  static Future<void> insertMovie(Movie inMovie) {}

  // Get a movie by its name
  static Future<Movie?> getMovieByName(String inName) {}

  // Update a movie
  static Future<int> updateMovie(Movie inMovie) {}


}
