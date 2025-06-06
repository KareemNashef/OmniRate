// Flutter imports
import 'package:hive/hive.dart';
import 'dart:async';

// Local imports
import 'package:omnirate/Shared/firebase_service.dart';
import 'package:omnirate/Shared/user_data.dart';

// Add or update a media entry in the user's list and synchronize it with Firebase
Future<void> addMediaEntry(String mediaType, String mediaName, double mediaRating, String mediaStatus) async {

  // Get user data
  final box = await Hive.openBox<UserData>('userBox');
  final firebaseService = FirebaseService();
  final userData = box.get('user');
  if (userData == null) throw Exception('No user data found');

  // Create or update media entry
  final entry = UserMediaEntry(name: mediaName, rating: mediaRating, status: mediaStatus);

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

  // Check if entry already exists with different status
  final existingEntry = targetList[mediaName];
  
  if (existingEntry != null && existingEntry.status != mediaStatus) {
    // Entry exists but status is different - this is a move operation
    // Update the existing entry with new status and rating
    targetList[mediaName] = UserMediaEntry(
      name: mediaName, 
      rating: mediaRating, 
      status: mediaStatus
    );
  } else {
    // Either new entry or updating existing entry with same status
    targetList[mediaName] = entry;
  }

  // Save user data
  await box.put('user', userData);
  await firebaseService.saveUserData(userData);
}

// Get the status of a media entry
Future<String?> getMediaStatus(String mediaType, String mediaName) async {

  // Get user data
  final box = await Hive.openBox<UserData>('userBox');
  final userData = box.get('user');
  if (userData == null) return null;

  switch (mediaType) {
    case 'MediaType.game':
      return userData.listGames[mediaName]?.status;
    case 'MediaType.show':
      return userData.listShows[mediaName]?.status;
    case 'MediaType.movie':
      return userData.listMovies[mediaName]?.status;
    default:
      return null;
  }
}

// Get the rating of a media entry
Future<String?> getMediaRating(String mediaType, String mediaName) async {

  // Get user data
  final box = await Hive.openBox<UserData>('userBox');
  final userData = box.get('user');
  if (userData == null) return null;

  switch (mediaType) {
    case 'MediaType.game':
      return userData.listGames[mediaName]?.rating.toString();
    case 'MediaType.show':
      return userData.listShows[mediaName]?.rating.toString();
    case 'MediaType.movie':
      return userData.listMovies[mediaName]?.rating.toString();
    default:
      return null;
  }
}

// Get a list of media entries by status
Future<List<UserMediaEntry>> getMediaByStatus(String mediaType, String mediaStatus) async {

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

  return list.values.where((entry) => entry.status.toLowerCase() == mediaStatus.toLowerCase()).toList();
}

// Get the username from Hive
Future<String?> getUsername() async {
  final box = await Hive.openBox<UserData>('userBox');
  final userData = box.get('user');
  if (userData == null) return null;
  return userData.userName;
}