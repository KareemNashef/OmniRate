class Game {
  final String id;
  final String name;
  final String thumbnailUrl;
  final String rating;
  final String releaseDate;
  final String developer;
  final String story;
  final List<String> genres;

  Game({
    required this.id,
    required this.name,
    required this.thumbnailUrl,
    required this.rating,
    required this.releaseDate,
    required this.developer,
    required this.story,
    required this.genres,
  });

  // Convert Game to Map for database insertion
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'thumbnailUrl': thumbnailUrl,
      'rating': rating,
      'releaseDate': releaseDate,
      'developer': developer,
      'story': story,
      'genres': genres.join(','),
    };
  }

  // Convert Map to Game instance
  factory Game.fromMap(Map<String, dynamic> map) {
    return Game(
      id: map['id'],
      name: map['name'],
      thumbnailUrl: map['thumbnailUrl'],
      rating: map['rating'],
      releaseDate: map['releaseDate'],
      developer: map['developer'],
      story: map['story'],
      genres: (map['genres'] as String).split(','),
    );
  }
}
