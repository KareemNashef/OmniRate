import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DatabaseHelper {
  static Database? _database;
  
  // Singleton pattern to get the database instance
  static Future<Database> getDatabase() async {
    if (_database != null) return _database!;
    
    // Get the application directory for storing database
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'game_database.db');
    
    // Open the database
    _database = await openDatabase(path, version: 1, onCreate: (db, version) {
      return db.execute(
        'CREATE TABLE games(id TEXT PRIMARY KEY, name TEXT, thumbnailUrl TEXT, rating TEXT, releaseDate TEXT, developer TEXT, story TEXT, genres TEXT)',
      );
    });
    return _database!;
  }

  // Insert a game into the database
  static Future<void> insertGame(Map<String, dynamic> gameData) async {
    final db = await getDatabase();
    await db.insert(
      'games',
      gameData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get a game by its ID
  static Future<Map<String, dynamic>?> getGameById(String id) async {
    final db = await getDatabase();
    final List<Map<String, dynamic>> result = await db.query(
      'games',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  // Get all games from the database
  static Future<List<Map<String, dynamic>>> getAllGames() async {
    final db = await getDatabase();
    return await db.query('games');
  }
}
