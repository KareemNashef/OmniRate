// Flutter imports
import 'package:hive/hive.dart';

// Code generation for Hive
part 'model_game.g.dart';

// ========== Game entry model ==========

@HiveType(typeId: 4)
class Game {
  // ===== Class variables =====

  // Main data
  @HiveField(0)
  final String name;
  
  @HiveField(1)
  final String thumbnailUrl;
  
  @HiveField(2)
  final double rating;

  // Additional info
  @HiveField(3)
  final String releaseDate;
  
  @HiveField(4)
  final String developer;
  
  @HiveField(5)
  final List<String> genres;
  
  @HiveField(6)
  final String overview;

  // Media specific data
  @HiveField(7)
  final String timeHaste;
  
  @HiveField(8)
  final String timeNormal;
  
  @HiveField(9)
  final String timeComplete;

  // User's data
  @HiveField(10)
  String status;
  
  @HiveField(11)
  double userRating;


  // ===== Class methods =====

  // Constructor
  Game({
    required this.name,
    required this.thumbnailUrl,
    this.rating = 0.0,

    this.releaseDate = 'N/A',
    this.developer = 'N/A',
    this.genres = const [],
    this.overview = 'N/A',

    this.timeHaste = 'N/A',
    this.timeNormal = 'N/A',
    this.timeComplete = 'N/A',

    this.status = 'N/A',
    this.userRating = 0.0,
  });

  // Convert to map
  Map<String, dynamic> toMap() => {
    'name': name,
    'thumbnailUrl': thumbnailUrl,
    'rating': rating,

    'releaseDate': releaseDate,
    'developer': developer,
    'genres': genres.join(','),
    'overview': overview,

    'timeHaste': timeHaste,
    'timeNormal': timeNormal,
    'timeComplete': timeComplete,

    'status': status,
    'userRating': userRating,
  };

  // Convert from map
  factory Game.fromMap(Map<String, dynamic> map) => Game(
    name: map['name'],
    thumbnailUrl: map['thumbnailUrl'],
    rating: map['rating'],

    releaseDate: map['releaseDate'],
    developer: map['developer'],
    genres: (map['genres'] as String).split(','),
    overview: map['overview'],

    timeHaste: map['timeHaste'],
    timeNormal: map['timeNormal'],
    timeComplete: map['timeComplete'],

    status: map['status'],
    userRating: map['userRating'],
  );
}
