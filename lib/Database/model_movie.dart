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
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String thumbnailUrl;

  @HiveField(10)
  final String artworkUrl;

  @HiveField(2)
  final double rating;

  // Additional info
  @HiveField(3)
  final String releaseStatus;

  @HiveField(4)
  final List<String> genres;

  @HiveField(5)
  final String overview;

  // Media specific data
  @HiveField(6)
  final String budget;

  @HiveField(7)
  final String revenue;

  // ===== MediaEntry Implementation =====

  @override
  MediaType get mediaType => MediaType.movie;


  // ===== Class methods =====

  // Constructor
  Movie({
    required this.name,
    required this.thumbnailUrl,
    this.artworkUrl = '',
    this.rating = 0.0,

    this.releaseStatus = 'N/A',
    this.genres = const [],
    this.overview = 'N/A',

    this.budget = 'N/A',
    this.revenue = 'N/A',
  });

  // Convert to map
  Map<String, dynamic> toMap() => {
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
