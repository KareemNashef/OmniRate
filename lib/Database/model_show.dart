// ==================== Show Entry Model ==================== //

// Flutter imports
import 'package:hive/hive.dart';

// Local imports
import 'package:omnirate/Database/model_entry.dart';

// Code generation for Hive
part 'model_show.g.dart';

// ========== Show entry model ==========

@HiveType(typeId: 3)
class Show implements MediaEntry {
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
  final String firstAir;

  @HiveField(7)
  final String lastAir;

  @HiveField(8)
  final int episodesNum;

  @HiveField(9)
  final int seasonsNum;

  @HiveField(10)
  final List<String> genres;

  @HiveField(11)
  final String overview;

  // Media specific data
  @HiveField(12)
  final List<String> seasonsNames;

  @HiveField(13)
  final List<String> seasonsThumbnailsUrls;

  @HiveField(14)
  final List<String> seasonsAirDates;

  @HiveField(15)
  final List<int> seasonsEpisodeCounts;

  @HiveField(16)
  final List<String> seasonsOverviews;

  @HiveField(17)
  final List<String> seasonsRatings;

  // Cast
  @HiveField(18)
  final List<String> castNames;

  // Crew
  @HiveField(19)
  final List<String> castImageUrls;

  // ===== MediaEntry Implementation =====

  @override
  MediaType get mediaType => MediaType.show;

  // ===== Class methods =====

  // Constructor
  Show({
    required this.id,
    required this.name,
    required this.thumbnailUrl,
    required this.artworkUrl,
    required this.rating,

    required this.releaseStatus,
    required this.firstAir,
    required this.lastAir,
    required this.episodesNum,
    required this.seasonsNum,
    required this.genres,
    required this.overview,

    required this.seasonsNames,
    required this.seasonsThumbnailsUrls,
    required this.seasonsAirDates,
    required this.seasonsEpisodeCounts,
    required this.seasonsOverviews,
    required this.seasonsRatings,

    required this.castNames,
    required this.castImageUrls,
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

    'castNames': castNames.join(','),
    'castImageUrls': castImageUrls.join(','),
  };

  // Convert from map
  factory Show.fromMap(Map<String, dynamic> map) => Show(
    id: map['id'],
    name: map['name'],
    thumbnailUrl: map['thumbnailUrl'],
    artworkUrl: map['backdropUrl'],
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
    seasonsEpisodeCounts:
        (map['seasonsEpisodeCounts'] as String)
            .split(',')
            .map((e) => int.tryParse(e) ?? 0)
            .toList(),
    seasonsOverviews: (map['seasonsOverviews'] as String).split(','),
    seasonsRatings: (map['seasonsRatings'] as String).split(','),

    castNames: (map['castNames'] as String).split(','),
    castImageUrls: (map['castImageUrls'] as String).split(','),
  );
}
