// Flutter imports
import 'package:hive/hive.dart';

// Local imports
import 'package:omnirate/Database/model_entry.dart';

// Code generation for Hive
part 'model_show.g.dart';

// ========== Show entry model ==========

@HiveType(typeId: 3)
class Show implements MediaEntry{
  // ===== Class variables =====

  // Main data
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String thumbnailUrl;

  @HiveField(17)
  final String artworkUrl;

  @HiveField(2)
  final double rating;

  // Additional info
  @HiveField(3)
  final String releaseStatus;

  @HiveField(4)
  final String firstAir;

  @HiveField(5)
  final String lastAir;

  @HiveField(6)
  final int episodesNum;

  @HiveField(7)
  final int seasonsNum;

  @HiveField(8)
  final List<String> genres;

  @HiveField(9)
  final String overview;

  // Media specific data
  @HiveField(10)
  final List<String> seasonsNames;

  @HiveField(11)
  final List<String> seasonsThumbnailsUrls;

  @HiveField(12)
  final List<String> seasonsAirDates;

  @HiveField(13)
  final List<int> seasonsEpisodeCounts;

  @HiveField(14)
  final List<String> seasonsOverviews;

  @HiveField(15)
  final List<String> seasonsRatings;

  // ===== MediaEntry Implementation =====

  @override
  MediaType get mediaType => MediaType.show;


  // ===== Class methods =====

  // Constructor
  Show({
    required this.name,
    required this.thumbnailUrl,
    this.artworkUrl = '',
    this.rating = 0.0,

    this.releaseStatus = 'N/A',
    this.firstAir = 'N/A',
    this.lastAir = 'N/A',
    this.episodesNum = 0,
    this.seasonsNum = 0,
    this.genres = const [],
    this.overview = 'N/A',

    this.seasonsNames = const [],
    this.seasonsThumbnailsUrls = const [],
    this.seasonsAirDates = const [],
    this.seasonsEpisodeCounts = const [],
    this.seasonsOverviews = const [],
    this.seasonsRatings = const [],
  });

  // Convert to map
  Map<String, dynamic> toMap() => {
    'name': name,
    'thumbnailUrl': thumbnailUrl,
    'backdropUrl': artworkUrl,
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
    'seasonsOverviews': seasonsOverviews.join(','),
    'seasonsRatings': seasonsRatings.join(','),
  };

  // Convert from map
  factory Show.fromMap(Map<String, dynamic> map) => Show(
    name: map['name'],
    thumbnailUrl: map['thumbnailUrl'],
    artworkUrl: map['backdropUrl'],
    rating: map['rating'],
    releaseStatus: map['releaseStatus'],
    firstAir: map['firstAir'],
    lastAir: map['lastAir'],
    episodesNum: map['episodesNum'],
    seasonsNum: map['seasonsNum'],
    genres: (map['genres'] as String).split(','),
    overview: map['overview'],
    seasonsNames: (map['seasonsNames'] as String).split(','),
    seasonsThumbnailsUrls: (map['seasonsThumbnailsUrls'] as String).split(','),
    seasonsAirDates: (map['seasonsAirDates'] as String).split(','),
    seasonsEpisodeCounts:
        (map['seasonsEpisodeCounts'] as String)
            .split(',')
            .map((e) => int.tryParse(e) ?? 0)
            .toList(),
    seasonsOverviews: (map['seasonsOverviews'] as String).split(','),
    seasonsRatings: (map['seasonsRatings'] as String).split(','),
  );
}
