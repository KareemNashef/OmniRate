// ==================== Game Entry Model ==================== //

// Flutter imports
import 'package:hive/hive.dart';

// Local imports
import 'package:omnirate/Database/model_entry.dart';

// Code generation for Hive
part 'model_game.g.dart';

// ========== Game entry model ==========

@HiveType(typeId: 4)
class Game implements MediaEntry {
  // ===== Class variables =====

  // Main data

  @override
  @HiveField(0)
  final String id;

  @override
  @HiveField(1)
  final String name;

  @override
  @HiveField(2)
  final String thumbnailUrl;

  @override
  @HiveField(3)
  final String artworkUrl;

  @override
  @HiveField(4)
  final String rating;

  // Additional info
  @HiveField(5)
  final String releaseDate;

  @HiveField(6)
  final String developer;

  @HiveField(7)
  final List<String> genres;

  @HiveField(8)
  final String overview;

  // Media specific data
  @HiveField(9)
  final String timeHaste;

  @HiveField(10)
  final String timeNormal;

  @HiveField(11)
  final String timeComplete;

  // ===== MediaEntry Implementation =====

  @override
  MediaType get mediaType => MediaType.game;

  // ===== Class methods =====

  // Constructor
  Game({
    required this.id,
    required this.name,
    required this.thumbnailUrl,
    required this.artworkUrl,
    required this.rating,

    required this.releaseDate,
    required this.developer,
    required this.genres,
    required this.overview,

    required this.timeHaste,
    required this.timeNormal,
    required this.timeComplete,
  });

  // Convert to map
  @override
  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'thumbnailUrl': thumbnailUrl,
    'artworkUrl': artworkUrl,
    'rating': rating,

    'releaseDate': releaseDate,
    'developer': developer,
    'genres': genres.join(','),
    'overview': overview,

    'timeHaste': timeHaste,
    'timeNormal': timeNormal,
    'timeComplete': timeComplete,
  };

  // Convert from map
  factory Game.fromMap(Map<String, dynamic> map) => Game(
    id: map['id'],
    name: map['name'],
    thumbnailUrl: map['thumbnailUrl'],
    artworkUrl: map['artworkUrl'],
    rating: map['rating'],

    releaseDate: map['releaseDate'],
    developer: map['developer'],
    genres: (map['genres'] as String).split(','),
    overview: map['overview'],

    timeHaste: map['timeHaste'],
    timeNormal: map['timeNormal'],
    timeComplete: map['timeComplete'],
  );

  @override
  String toString() {
    return '''
      ID: $id
      Name: $name
      Thumbnail: $thumbnailUrl
      Artwork: $artworkUrl
      Rating: $rating
      Release Date: $releaseDate
      Developer: $developer
      Genres: ${genres.join(', ')}
      Overview: $overview
      Time (Haste): $timeHaste
      Time (Normal): $timeNormal
      Time (Complete): $timeComplete
      ''';
  }
}
