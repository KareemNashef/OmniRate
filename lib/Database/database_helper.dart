// Flutter imports
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

// Import models
import 'package:omnirate/Database/model_game.dart';
import 'package:omnirate/Database/model_movie.dart';
import 'package:omnirate/Database/model_show.dart';

// ========== Database helper ========== //

class DatabaseHelper {
  // Database instance
  static Database? _database;

  // Table names
  static const String tableGames = 'games';
  static const String tableMovies = 'movies';
  static const String tableShows = 'shows';

  // Singleton pattern to get the database instance
  static Future<Database> getDatabase() async {
    if (_database != null) return _database!;

    // Get the application directory for storing database
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'media_tracker.db');

    // Open the database
    _database = await openDatabase(path, onCreate: _createDatabase);
    return _database!;
  }

  // Create database tables
  static Future<void> _createDatabase(Database db, int version) async {
    // Create games table
    await db.execute('''
      CREATE TABLE $tableGames(
        name TEXT PRIMARY KEY,
        thumbnailUrl TEXT,
        rating TEXT,
        releaseDate TEXT,
        developer TEXT,
        genres TEXT,
        overview TEXT,
        timeHaste TEXT,
        timeNormal TEXT,
        timeComplete TEXT,
        status TEXT,
        userRating TEXT
      )
    ''');

    // Create movies table
    await db.execute('''
      CREATE TABLE $tableMovies(
        name TEXT PRIMARY KEY,
        thumbnailUrl TEXT,
        rating TEXT,
        releaseDate TEXT,
        genres TEXT,
        overview TEXT,
        budget TEXT,
        revenue TEXT,
        status TEXT,
        userRating TEXT
      )
    ''');

    // Create shows table
    await db.execute('''
      CREATE TABLE $tableShows(
        name TEXT PRIMARY KEY,
        thumbnailUrl TEXT,
        rating TEXT,
        releaseDate TEXT,
        firstAir TEXT,
        lastAir TEXT,
        episodesNum TEXT,
        seasonsNum TEXT,
        genres TEXT,
        overview TEXT,
        seasonsNames TEXT,
        seasonsThumbnailsUrls TEXT,
        seasonsAirDates TEXT,
        seasonsEpisodeCounts TEXT,
        seasonsOvervies TEXT,
        status TEXT,
        userRating TEXT
      )
    ''');
  }

  // ========== Game Methods ========== //

  // Insert a game into the database
  static Future<void> insertGame(Game game) async {
    final db = await getDatabase();
    await db.insert(
      tableGames,
      game.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get a game by its name
  static Future<Game?> getGameByName(String name) async {
    final db = await getDatabase();
    final List<Map<String, dynamic>> result = await db.query(
      tableGames,
      where: 'name = ?',
      whereArgs: [name],
    );
    if (result.isNotEmpty) {
      return Game.fromMap(result.first);
    }
    return null;
  }

  // ============================== REMOVE LATER IF WE DONT USE ============================== //

  // Get all games from the database
  static Future<List<Game>> getAllGames() async {
    final db = await getDatabase();
    final List<Map<String, dynamic>> maps = await db.query(tableGames);
    return List.generate(maps.length, (i) => Game.fromMap(maps[i]));
  }

  // Update a game
  static Future<int> updateGame(Game game) async {
    final db = await getDatabase();
    return await db.update(
      tableGames,
      game.toMap(),
      where: 'name = ?',
      whereArgs: [game.name],
    );
  }

  // Delete a game
  static Future<int> deleteGame(String name) async {
    final db = await getDatabase();
    return await db.delete(tableGames, where: 'name = ?', whereArgs: [name]);
  }

  // ========================================================================================= //

  // ========== Movie Methods ========== //

  // Insert a movie into the database
  static Future<void> insertMovie(Movie movie) async {
    final db = await getDatabase();
    await db.insert(
      tableMovies,
      movie.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get a movie by its name
  static Future<Movie?> getMovieByName(String name) async {
    final db = await getDatabase();
    final List<Map<String, dynamic>> result = await db.query(
      tableMovies,
      where: 'name = ?',
      whereArgs: [name],
    );
    if (result.isNotEmpty) {
      return Movie.fromMap(result.first);
    }
    return null;
  }

  // ============================== REMOVE LATER IF WE DONT USE ============================== //

  // Get all movies from the database
  static Future<List<Movie>> getAllMovies() async {
    final db = await getDatabase();
    final List<Map<String, dynamic>> maps = await db.query(tableMovies);
    return List.generate(maps.length, (i) => Movie.fromMap(maps[i]));
  }

  // Update a movie
  static Future<int> updateMovie(Movie movie) async {
    final db = await getDatabase();
    return await db.update(
      tableMovies,
      movie.toMap(),
      where: 'name = ?',
      whereArgs: [movie.name],
    );
  }

  // Delete a movie
  static Future<int> deleteMovie(String name) async {
    final db = await getDatabase();
    return await db.delete(tableMovies, where: 'name = ?', whereArgs: [name]);
  }

  // ========================================================================================= //

  // ========== Show Methods ========== //

  // Insert a show into the database
  static Future<void> insertShow(Show show) async {
    final db = await getDatabase();
    await db.insert(
      tableShows,
      show.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get a show by its name
  static Future<Show?> getShowByName(String name) async {
    final db = await getDatabase();
    final List<Map<String, dynamic>> result = await db.query(
      tableShows,
      where: 'name = ?',
      whereArgs: [name],
    );
    if (result.isNotEmpty) {
      return Show.fromMap(result.first);
    }
    return null;
  }

  // ============================== REMOVE LATER IF WE DONT USE ============================== //

  // Get all shows from the database
  static Future<List<Show>> getAllShows() async {
    final db = await getDatabase();
    final List<Map<String, dynamic>> maps = await db.query(tableShows);
    return List.generate(maps.length, (i) => Show.fromMap(maps[i]));
  }

  // Update a show
  static Future<int> updateShow(Show show) async {
    final db = await getDatabase();
    return await db.update(
      tableShows,
      show.toMap(),
      where: 'name = ?',
      whereArgs: [show.name],
    );
  }

  // Delete a show
  static Future<int> deleteShow(String name) async {
    final db = await getDatabase();
    return await db.delete(tableShows, where: 'name = ?', whereArgs: [name]);
  }

  // ========================================================================================= //
  
  // ========== General Methods ========== //

  // Check if a media item exists in any table
  static Future<bool> mediaExists(String name) async {
    final game = await getGameByName(name);
    if (game != null) return true;

    final movie = await getMovieByName(name);
    if (movie != null) return true;

    final show = await getShowByName(name);
    if (show != null) return true;

    return false;
  }

  // Delete database file (for testing or reset)
  static Future<void> deleteDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'media_tracker.db');
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }
}
