// ==================== Base Entry Model ==================== //

// Enum to identify the type of media entry.
enum MediaType { game, movie, show }

// Abstract class that serves as a common interface for all media types.
abstract class MediaEntry {
  // A unique identifier for the media type.
  MediaType get mediaType;

  // ===== Common Main Data =====
  String get id;
  String get name;
  String get thumbnailUrl;
  String get artworkUrl;
  String get rating;

  // ===== Common Methods =====
  Map<String, dynamic> toMap();
}
