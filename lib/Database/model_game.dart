// ========== Game entry model ==========

class Game {
  // ===== Class variables =====

  // Main data
  final String name;
  final String thumbnailUrl;
  final String rating;

  // Additional info
  final String releaseDate;
  final String developer;
  final List<String> genres;
  final String overview;

  // Media specific data
  final String timeHaste;
  final String timeNormal;
  final String timeComplete;

  // User's data
  String status;
  String userRating;

  // ===== Class methods =====

  // Constructor
  Game({
    required this.name,
    required this.thumbnailUrl,
    this.rating = 'N/A',

    this.releaseDate = 'N/A',
    this.developer = 'N/A',
    this.genres = const [],
    this.overview = 'N/A',

    this.timeHaste = 'N/A',
    this.timeNormal = 'N/A',
    this.timeComplete = 'N/A',

    this.status = 'N/A',
    this.userRating = 'N/A',
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
