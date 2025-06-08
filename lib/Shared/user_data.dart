// ==================== User Data Class ==================== //

// Flutter imports
import 'package:hive/hive.dart';

// Code generation for Hive
part 'user_data.g.dart';

// User data class
@HiveType(typeId: 0)
class UserData {
  // User credentials
  @HiveField(0)
  String userName;
  @HiveField(1)
  String email;

  // User lists
  @HiveField(2)
  Map<String, UserMediaEntry> listGames;
  @HiveField(3)
  Map<String, UserMediaEntry> listShows;
  @HiveField(4)
  Map<String, UserMediaEntry> listMovies;

  // Constructor
  UserData({
    required this.userName,
    required this.email,
    required this.listGames,
    required this.listShows,
    required this.listMovies,
  });

  // Convert to map
  Map<String, dynamic> toMap() => {
    'userName': userName,
    'listGames': listGames.map((k, v) => MapEntry(k, v.toMap())),
    'listShows': listShows.map((k, v) => MapEntry(k, v.toMap())),
    'listMovies': listMovies.map((k, v) => MapEntry(k, v.toMap())),
    'email': email,
  };

  // Convert from map
  factory UserData.fromMap(Map<String, dynamic> map) => UserData(
    userName: map['userName'] ?? '',
    listGames:
        (map['listGames'] as Map?)?.map(
          (k, v) =>
              MapEntry(k, UserMediaEntry.fromMap(Map<String, dynamic>.from(v))),
        ) ??
        {},
    listShows:
        (map['listShows'] as Map?)?.map(
          (k, v) =>
              MapEntry(k, UserMediaEntry.fromMap(Map<String, dynamic>.from(v))),
        ) ??
        {},
    listMovies:
        (map['listMovies'] as Map?)?.map(
          (k, v) =>
              MapEntry(k, UserMediaEntry.fromMap(Map<String, dynamic>.from(v))),
        ) ??
        {},
    email: map['email'] ?? '',
  );

  // Convert to string
  @override
  String toString() {
    return 'UserData(userName: $userName, listGames: $listGames, listShows: $listShows, listMovies: $listMovies, email: $email)';
  }
}

// Media entry class
@HiveType(typeId: 1)
class UserMediaEntry {
  // Media details
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String rating;

  @HiveField(3)
  String status;

  // Constructor
  UserMediaEntry({
    required this.id,
    required this.name,
    required this.rating,
    required this.status,
  });

  // Convert to map
  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'rating': rating,
    'status': status,
  };

  // Convert from map
  factory UserMediaEntry.fromMap(Map<String, dynamic> map) => UserMediaEntry(
    id: map['id'] ?? '0',
    name: map['name'] ?? 'N/A',
    rating: map['rating'] ?? "0.0",
    status: map['status'] ?? 'N/A',
  );

  // Convert to string
  @override
  String toString() =>
      'MediaEntry( id: $id, name: $name, rating: $rating, status: $status)';
}
