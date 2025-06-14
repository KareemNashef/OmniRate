// ==================== Firebase Service ==================== //

// Flutter imports
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:omnirate/Database/model_game.dart';
import 'package:omnirate/Database/model_movie.dart';
import 'package:omnirate/Database/model_show.dart';

// Local imports
import 'package:omnirate/Shared/user_data.dart';
import 'package:omnirate/Database/model_entry.dart';

// ========== Firebase Service Class ========== //

class FirebaseService {
  // Initialize services
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ===== Authentication ===== //

  // Sign in
  Future<User?> signIn(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return cred.user;
  }

  // Sign up
  Future<User?> signUp(String email, String password, String username) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = cred.user;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).set({
        'username': username,
        'email': email,
      });
    }
    return user;
  }

  // Change username
  Future<void> changeUsername(String newUsername) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'userName': newUsername,
      });
    }
  }

  // Change password
  Future<void> changePassword(String newPassword) async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.updatePassword(newPassword);
    }
  }

  // Sign out
  Future<void> signOut() async => _auth.signOut();

  // ===== User Data ===== //

  // Save user data
  Future<void> saveUserData(UserData data) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user signed in');

    await _firestore.collection('users').doc(user.uid).set(data.toMap());
  }

  // Load user data
  Future<UserData?> loadUserData() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection('users').doc(user.uid).get();

    if (!doc.exists) return null;

    return UserData.fromMap(doc.data()!);
  }

  // ===== Reviews ===== //

  // Get all reviews
  Future<List<Map<String, dynamic>>> getReviews(MediaEntry inEntry) async {
    final doc =
        await _firestore
            .collection('reviews')
            .doc(inEntry.mediaType.toString())
            .get();
    final data = doc.data();
    if (data == null || data[inEntry.id] == null) return [];
    return List<Map<String, dynamic>>.from(data[inEntry.id]);
  }

  // Add review
  Future<void> addReview(
    MediaEntry inEntry,
    String inRating,
    String inReview,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    final userName =
        userDoc.data()?['userName'] ?? user.displayName ?? 'Unknown';

    final reviewData = {
      'userEmail': user.email,
      'userName': userName,
      'rating': inRating,
      'review': inReview,
      'timestamp': DateTime.now(),
    };

    await _firestore
        .collection('reviews')
        .doc(inEntry.mediaType.toString())
        .set({
          inEntry.id: FieldValue.arrayUnion([reviewData]),
        }, SetOptions(merge: true));
  }

  Future<void> deleteReview(MediaEntry inEntry, DateTime inTime) async {
    final user = FirebaseAuth.instance.currentUser;
    final doc =
        await _firestore
            .collection('reviews')
            .doc(inEntry.mediaType.toString())
            .get();

    final comments = List<Map<String, dynamic>>.from(
      doc.data()?[inEntry.id] ?? [],
    );

    comments.removeWhere((c) {
      final ts = c['timestamp'];
      if (ts is Timestamp) {
        final tsDate = ts.toDate();
        return c['userEmail'] == user?.email && tsDate == inTime;
      }
      return false;
    });

    await _firestore
        .collection('reviews')
        .doc(inEntry.mediaType.toString())
        .set({inEntry.id: comments}, SetOptions(merge: true));
  }

  // ===== Shared Database ===== //

  // Save entry to database
  Future<void> saveEntry(MediaEntry entry) async {
    await _firestore.collection('database').doc(entry.mediaType.toString()).set(
      {entry.id: entry.toMap()},
      SetOptions(merge: true),
    );
  }

  // Load entry from database
  Future<MediaEntry?> loadEntry(String type, String id) async {
    final doc = await _firestore.collection('database').doc(type).get();
    final data = doc.data();
    if (data == null || !data.containsKey(id)) return null;

    final entryData = data[id];

    switch (type) {
      case 'MediaType.game':
        return Game.fromMap(entryData);
      case 'MediaType.show':
        return Show.fromMap(entryData);
      case 'MediaType.movie':
        return Movie.fromMap(entryData);
      default:
        return null;
    }
  }
}
