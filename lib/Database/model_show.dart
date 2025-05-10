class Show {
  // Main data
  final String name;
  final String thumbnailUrl;
  final String rating;

  // Additional info
  final String releaseStatus;
  final String firstAir;
  final String lastAir;
  final String episodesNum;
  final String seasonsNum;
  final List<String> genres;
  final String overview;

  // Extra data
  final List<String> seasonsNames;
  final List<String> seasonsThumbnailsUrls;
  final List<String> seasonsAirDates;
  final List<String> seasonsEpisodeCounts;
  final List<String> seasonsOvervies;

  // User's data
  String status;
  String userRating;

  Show({
    required this.name,
    required this.thumbnailUrl,
    this.rating = 'N/A',

    this.releaseStatus = 'N/A',
    this.firstAir = 'N/A',
    this.lastAir = 'N/A',
    this.episodesNum = 'N/A',
    this.seasonsNum = 'N/A',
    this.genres = const [],
    this.overview = 'N/A',

    this.seasonsNames = const [],
    this.seasonsThumbnailsUrls = const [],
    this.seasonsAirDates = const [],
    this.seasonsEpisodeCounts = const [],
    this.seasonsOvervies = const [],

    this.status = 'N/A',
    this.userRating = 'N/A',
  });

  Map<String, dynamic> toMap() => {
    'name': name,
    'thumbnailUrl': thumbnailUrl,
    'rating': rating,

    'releaseDate': releaseStatus,
    'firstAir': firstAir,
    'lastAir': lastAir,
    'episodesNum': episodesNum,
    'seasonsNum': seasonsNum,
    'genres': genres.join(','),
    'overview': overview,

    'seasonsNames': seasonsNames.join(','),
    'seasonsThumbnailsUrls': seasonsThumbnailsUrls.join(','),
    'seasonsAirDates': seasonsAirDates.join(','),
    'seasonsEpisodeCounts': seasonsEpisodeCounts.join(','),
    'seasonsOvervies': seasonsOvervies.join(','),

    'status': status,
    'userRating': userRating,
  };

  factory Show.fromMap(Map<String, dynamic> map) => Show(
    name: map['name'],
    thumbnailUrl: map['thumbnailUrl'],
    rating: map['rating'],

    releaseStatus: map['releaseDate'],
    firstAir: map['firstAir'],
    lastAir: map['lastAir'],
    episodesNum: map['episodesNum'],
    seasonsNum: map['seasonsNum'],
    genres: (map['genres'] as String).split(','),
    overview: map['overview'],

    seasonsNames: (map['seasonsNames'] as String).split(','),
    seasonsThumbnailsUrls: (map['seasonsThumbnailsUrls'] as String).split(','),
    seasonsAirDates: (map['seasonsAirDates'] as String).split(','),
    seasonsEpisodeCounts: (map['seasonsEpisodeCounts'] as String).split(','),
    seasonsOvervies: (map['seasonsOvervies'] as String).split(','),

    status: map['status'],
    userRating: map['userRating'],
  );
}
