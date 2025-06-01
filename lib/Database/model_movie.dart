// ========== Movie entry model ==========

class Movie {
  // ===== Class variables =====

  // Main data
  final String name;
  final String thumbnailUrl;
  final String rating;

  // Additional info
  final String releaseStatus;
  final List<String> genres;
  final String overview;

  // Media specific data
  final String budget;
  final String revenue;

  // User's data
  String status;
  String userRating;

  // ===== Class methods =====

  // Constructor
  Movie({
    required this.name,
    required this.thumbnailUrl,
    this.rating = 'N/A',

    this.releaseStatus = 'N/A',
    this.genres = const [],
    this.overview = 'N/A',

    this.budget = 'N/A',
    this.revenue = 'N/A',

    this.status = 'N/A',
    this.userRating = 'N/A',
  });

  // Convert to map
  Map<String, dynamic> toMap() => {
    'name': name,
    'thumbnailUrl': thumbnailUrl,
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
