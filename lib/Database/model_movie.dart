// ==================== Movie Entry Model ==================== //

// Flutter imports
import 'package:hive/hive.dart';

// Local imports
import 'package:omnirate/Database/model_entry.dart';

// Code generation for Hive
part 'model_movie.g.dart';

// ========== Movie entry model ==========

@HiveType(typeId: 2)
class Movie implements MediaEntry{
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
  final String releaseStatus;

  @HiveField(6)
  final List<String> genres;

  @HiveField(7)
  final String overview;

  // Media specific data
  @HiveField(8)
  final String budget;

  @HiveField(9)
  final String revenue;

  // ===== MediaEntry Implementation =====

  @override
  MediaType get mediaType => MediaType.movie;


  // ===== Class methods =====

  // Constructor
  Movie({
    required this.id,
    required this.name,
    required this.thumbnailUrl,
    required this.artworkUrl,
    required this.rating,

    required this.releaseStatus,
    required this.genres,
    required this.overview,

    required this.budget,
    required this.revenue,
  });

  // Convert to map
  @override
  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'thumbnailUrl': thumbnailUrl,
    'backdropUrl': artworkUrl,
    'rating': rating,

    'releaseDate': releaseStatus,
    'genres': genres.join(','),
    'overview': overview,

    'budget': budget,
    'revenue': revenue,
  };

  // Convert from map
  factory Movie.fromMap(Map<String, dynamic> map) => Movie(
    id: map['id'],
    name: map['name'],
    thumbnailUrl: map['thumbnailUrl'],
    artworkUrl: map['backdropUrl'],
    rating: map['rating'],

    releaseStatus: map['releaseDate'],
    genres: (map['genres'] as String).split(','),
    overview: map['overview'],

    budget: map['budget'],
    revenue: map['revenue'],
  );

  // Convert to string
@override
String toString() => '''
Movie:
  ID: $id
  Name: $name
  Thumbnail URL: $thumbnailUrl
  Backdrop URL: $artworkUrl
  Rating: $rating
  Release Status: $releaseStatus
  Genres: ${genres.join(', ')}
  Overview: $overview
  Budget: $budget
  Revenue: $revenue
''';
}
