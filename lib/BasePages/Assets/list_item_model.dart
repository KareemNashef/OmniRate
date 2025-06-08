// A helper class to bundle media with its user-specific list data.
class MediaListItem {
  final dynamic media; // This will be a Game, Show, or Movie object
  final int? rating;   // The user's rating for this media

  MediaListItem({
    required this.media,
    this.rating,
  });

  // Helper getters to avoid type casting everywhere
  String? get name => media.name;
  String? get thumbnailUrl => media.thumbnailUrl;
}