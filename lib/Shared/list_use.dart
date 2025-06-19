// ==================== User List Functions ==================== //

// Flutter imports
import 'package:hive/hive.dart';
import 'dart:async';

// Local imports
import 'package:omnirate/Shared/firebase_service.dart';
import 'package:omnirate/Shared/user_data.dart';

// ===== User List Functions ===== //

// Add or update a media entry in the user's list and synchronize it with Firebase
Future<void> addMediaEntry(
  String mediaType,
  String mediaId,
  String mediaName,
  String mediaRating,
  String mediaStatus,
) async {
  // Get user data
  final box = await Hive.openBox<UserData>('userBox');
  final firebaseService = FirebaseService();
  final userData = box.get('user');
  if (userData == null) throw Exception('No user data found');

  // Create or update media entry
  final entry = UserMediaEntry(
    id: mediaId,
    name: mediaName,
    rating: mediaRating,
    status: mediaStatus,
  );

  Map<String, UserMediaEntry> targetList;

  // Get the appropriate list based on media type
  switch (mediaType) {
    case 'MediaType.game':
      targetList = userData.listGames;
      break;
    case 'MediaType.show':
      targetList = userData.listShows;
      break;
    case 'MediaType.movie':
      targetList = userData.listMovies;
      break;
    default:
      throw Exception('Invalid media type');
  }

  // Add or update media entry
  targetList[mediaId] = entry;

  // Save user data
  await box.put('user', userData);
  await firebaseService.saveUserData(userData);
}

// Remove a media entry from the user's list and synchronize it with Firebase
Future<void> removeMediaEntry(String mediaType, String mediaId) async {
  // Get user data
  final box = await Hive.openBox<UserData>('userBox');
  final firebaseService = FirebaseService();
  final userData = box.get('user');
  if (userData == null) throw Exception('No user data found');

  // Remove media entry
  switch (mediaType) {
    case 'MediaType.game':
      userData.listGames.remove(mediaId);
      break;
    case 'MediaType.show':
      userData.listShows.remove(mediaId);
      break;
    case 'MediaType.movie':
      userData.listMovies.remove(mediaId);
      break;
    default:
      throw Exception('Invalid media type');
  }

  // Save user data
  await box.put('user', userData);
  await firebaseService.saveUserData(userData);

  return;
}

// Get the status of a media entry
Future<String?> getMediaStatus(String mediaType, String mediaID) async {
  // Get user data
  final box = await Hive.openBox<UserData>('userBox');
  final userData = box.get('user');
  if (userData == null) return null;

  switch (mediaType) {
    case 'MediaType.game':
      return userData.listGames[mediaID]?.status;
    case 'MediaType.show':
      return userData.listShows[mediaID]?.status;
    case 'MediaType.movie':
      return userData.listMovies[mediaID]?.status;
    default:
      return null;
  }
}

// Get the rating of a media entry
Future<String?> getMediaRating(String mediaType, String mediaID) async {
  // Get user data
  final box = await Hive.openBox<UserData>('userBox');
  final userData = box.get('user');
  if (userData == null) return null;

  switch (mediaType) {
    case 'MediaType.game':
      return userData.listGames[mediaID]?.rating.toString();
    case 'MediaType.show':
      return userData.listShows[mediaID]?.rating.toString();
    case 'MediaType.movie':
      return userData.listMovies[mediaID]?.rating.toString();
    default:
      return null;
  }
}

// Get a list of media entries by status
Future<List<UserMediaEntry>> getMediaByStatus(
  String mediaType,
  String mediaStatus,
) async {
  // Get user data
  final box = await Hive.openBox<UserData>('userBox');
  final userData = box.get('user');
  if (userData == null) return [];

  Map<String, UserMediaEntry> list;

  switch (mediaType) {
    case 'Games':
      list = userData.listGames;
      break;
    case 'Shows':
      list = userData.listShows;
      break;
    case 'Movies':
      list = userData.listMovies;
      break;
    default:
      return [];
  }

  return list.values
      .where((entry) => entry.status.toLowerCase() == mediaStatus.toLowerCase())
      .toList();
}

// Get a list of media entries by type
Future<List<UserMediaEntry>> getMediaByType(String mediaType) async {
  // Get user data
  final box = await Hive.openBox<UserData>('userBox');
  final userData = box.get('user');
  if (userData == null) return [];

  Map<String, UserMediaEntry> list;

  switch (mediaType) {
    case 'Games':
      list = userData.listGames;
      break;
    case 'Shows':
      list = userData.listShows;
      break;
    case 'Movies':
      list = userData.listMovies;
      break;
    default:
      return [];
  }

  return list.values.toList();
}

// Get the username from Hive
Future<String?> getUsername() async {
  final box = await Hive.openBox<UserData>('userBox');
  final userData = box.get('user');
  if (userData == null) return null;
  return userData.userName;
}

// Get the avatar index from Hive
Future<int?> getAvatarIndex() async {
  final box = await Hive.openBox<UserData>('userBox');
  final userData = box.get('user');
  if (userData == null) return null;
  return userData.avatarIndex;
}