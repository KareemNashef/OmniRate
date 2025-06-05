// Enum to identify the type of media entry.
enum MediaType {
  game,
  movie,
  show,
}

// Abstract class that serves as a common interface for all media types.
abstract class MediaEntry {
  // A unique identifier for the media type.
  MediaType get mediaType;

  // ===== Common Main Data =====
  String get name;
  String get thumbnailUrl;
  String get artworkUrl;
  double get rating;

  // ===== Common Additional Info =====
  List<String> get genres;
  String get overview;

  // ===== Common Methods =====
  Map<String, dynamic> toMap();
}
