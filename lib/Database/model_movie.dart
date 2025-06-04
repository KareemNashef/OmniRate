// Flutter imports
import 'package:hive/hive.dart';

// Code generation for Hive
part 'model_movie.g.dart';

// ========== Movie entry model ==========

@HiveType(typeId: 2)
class Movie {
  // ===== Class variables =====

  // Main data
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String thumbnailUrl;

  @HiveField(10)
  final String backdropUrl;

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

  // User's data
  @HiveField(8)
  String status;

  @HiveField(9)
  double userRating;

  // ===== Class methods =====

  // Constructor
  Movie({
    required this.name,
    required this.thumbnailUrl,
    this.backdropUrl = '',
    this.rating = 0.0,

    this.releaseStatus = 'N/A',
    this.genres = const [],
    this.overview = 'N/A',

    this.budget = 'N/A',
    this.revenue = 'N/A',

    this.status = 'N/A',
    this.userRating = 0.0,
  });

  // Convert to map
  Map<String, dynamic> toMap() => {
    'name': name,
    'thumbnailUrl': thumbnailUrl,
    'backdropUrl': backdropUrl,
    'rating': rating,

    'releaseDate': releaseStatus,
    'genres': genres.join(','),
    'overview': overview,

    'budget': budget,
    'revenue': revenue,

    'status': status,
    'userRating': userRating,
  };

  // Convert from map
  factory Movie.fromMap(Map<String, dynamic> map) => Movie(
    name: map['name'],
    thumbnailUrl: map['thumbnailUrl'],
    backdropUrl: map['backdropUrl'],
    rating: map['rating'],

    releaseStatus: map['releaseDate'],
    genres: (map['genres'] as String).split(','),
    overview: map['overview'],

    budget: map['budget'],
    revenue: map['revenue'],

    status: map['status'],
    userRating: map['userRating'],
  );
}
