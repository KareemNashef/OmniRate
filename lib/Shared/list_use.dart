// Flutter imports
import 'package:hive/hive.dart';
import 'dart:async';

// Local imports
import 'package:omnirate/Shared/firebase_service.dart';
import 'package:omnirate/Shared/user_data.dart';

// Add a media entry to the user's list and synchronize it with Firebase
Future<void> addMediaEntry(String mediaType, String mediaName, double mediaRating, String mediaStatus) async {

  // Get user data
  final box = await Hive.openBox<UserData>('userBox');
  final firebaseService = FirebaseService();
  final userData = box.get('user');
  if (userData == null) throw Exception('No user data found');

  // Add media entry
  final entry = MediaEntry(name: mediaName, rating: mediaRating, status: mediaStatus);

  switch (mediaType) {
    case 'Game':
      userData.listGames[mediaName] = entry;
      break;
    case 'Show':
      userData.listShows[mediaName] = entry;
      break;
    case 'Movie':
      userData.listMovies[mediaName] = entry;
      break;
    default:
      throw Exception('Invalid media type');
  }

  // Save user data
  await box.put('user', userData);
  await firebaseService.saveUserData(userData);
}

// Get a list of media entries by status
Future<List<MediaEntry>> getMediaByStatus(String mediaType, String mediaStatus) async {

  // Get user data
  final box = await Hive.openBox<UserData>('userBox');
  final userData = box.get('user');
  if (userData == null) return [];

  Map<String, MediaEntry> list;

  switch (mediaType) {
    case 'Game':
      list = userData.listGames;
      break;
    case 'Show':
      list = userData.listShows;
      break;
    case 'Movie':
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