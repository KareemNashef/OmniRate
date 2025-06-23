// ==================== Firebase Service ==================== //

// Flutter imports
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:omnirate/Database/model_game.dart';
import 'package:omnirate/Database/model_movie.dart';
import 'package:omnirate/Database/model_show.dart';
import 'package:omnirate/Feed/friend_model.dart';
import 'package:omnirate/Feed/review_model.dart';

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

  // Change avatar
  Future<void> changeAvatar(int newAvatar) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'avatarIndex': newAvatar,
      });
    }
  }

  Future<void> changePassword(
    String email,
    String currentPassword,
    String newPassword,
  ) async {
    final user = _auth.currentUser;
    if (user != null) {
      final cred = EmailAuthProvider.credential(
        email: email,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(cred);
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

  Future<int?> getAvatarIndexFirebase(String uid) async {
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return doc.data()?['avatarIndex'] as int?;
  }

  // Get all reviews for a media entry
  Future<List<Review>> getReviews(MediaEntry inEntry) async {
    final query =
        await _firestore
            .collection('reviews')
            .doc(inEntry.mediaType.toString())
            .collection(inEntry.id)
            .orderBy('timestamp', descending: false)
            .get();

    return query.docs.map((doc) {
      final data = doc.data();
      return Review(
        entryId: data['entryId'] ?? inEntry.id,
        mediaType: data['mediaType'] ?? inEntry.mediaType.toString(),
        entryName: inEntry.name,
        rating: data['rating'] ?? '',
        review: data['review'] ?? '',
        reviewId: doc.id,
        timestamp: (data['timestamp'] as Timestamp).toDate(),
        userEmail: data['userEmail'] ?? '',
        userId: data['userId'] ?? '',
        userName: data['userName'] ?? '',
      );
    }).toList();
  }

  // Add a review as a document under both media and user
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

    final reviewId = _firestore.collection('dummy').doc().id; // generate ID

    final reviewData = {
      'userId': user.uid,
      'userEmail': user.email,
      'userName': userName,
      'rating': inRating,
      'review': inReview,
      'timestamp': DateTime.now(),
      'mediaType': inEntry.mediaType.toString(),
      'entryId': inEntry.id,
      'reviewId': reviewId,
      'entryName': inEntry.name,
    };

    final batch = _firestore.batch();

    final mediaRef = _firestore
        .collection('reviews')
        .doc(inEntry.mediaType.toString())
        .collection(inEntry.id)
        .doc(reviewId);

    final userRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('reviews')
        .doc(reviewId);

    batch.set(mediaRef, reviewData);
    batch.set(userRef, reviewData);
    await batch.commit();
  }

  // Delete review by matching user and timestamp
  Future<void> deleteReview(MediaEntry inEntry, DateTime inTime) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final query =
        await _firestore
            .collection('reviews')
            .doc(inEntry.mediaType.toString())
            .collection(inEntry.id)
            .where('userId', isEqualTo: user.uid)
            .where('timestamp', isEqualTo: Timestamp.fromDate(inTime))
            .get();

    for (var doc in query.docs) {
      final reviewId = doc.id;

      final mediaRef = doc.reference;
      final userRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('reviews')
          .doc(reviewId);

      final batch = _firestore.batch();
      batch.delete(mediaRef);
      batch.delete(userRef);
      await batch.commit();
    }
  }

  // Get all reviews by a user (from user profile)
  Future<List<Review>> getUserReviews(String uid) async {
    final query =
        await _firestore
            .collection('users')
            .doc(uid)
            .collection('reviews')
            .orderBy('timestamp', descending: true)
            .get();

    return query.docs.map((doc) {
      final data = doc.data();
      return Review(
        entryId: data['entryId'],
        mediaType: data['mediaType'],
        entryName: data['entryName'],
        rating: data['rating'] ?? '',
        review: data['review'] ?? '',
        reviewId: doc.id,
        timestamp: (data['timestamp'] as Timestamp).toDate(),
        userEmail: data['userEmail'] ?? '',
        userId: data['userId'] ?? '',
        userName: data['userName'] ?? '',
      );
    }).toList();
  }

  // ===== Friends ===== //

  // Send a friend request
  Future<void> sendFriendRequest(String friendId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Get current user's info
    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    final userName =
        userDoc.data()?['userName'] ?? user.displayName ?? 'Unknown';

    // Get friend's info
    final friendDoc = await _firestore.collection('users').doc(friendId).get();
    final friendName = friendDoc.data()?['userName'] ?? 'Unknown';

    final batch = _firestore.batch();

    // Add to current user's "sent requests" (requested status)
    final currentUserFriendRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('friends')
        .doc(friendId);

    batch.set(currentUserFriendRef, {
      'id': friendId,
      'name': friendName,
      'status': 'requested',
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Add to friend's "received requests" (pending status)
    final friendUserFriendRef = _firestore
        .collection('users')
        .doc(friendId)
        .collection('friends')
        .doc(user.uid);

    batch.set(friendUserFriendRef, {
      'id': user.uid,
      'name': userName,
      'status': 'pending',
      'timestamp': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  // Accept a friend request
  Future<void> acceptFriendRequest(Friend friend) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final batch = _firestore.batch();

    // Update current user's friend status to accepted
    final currentUserFriendRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('friends')
        .doc(friend.id);

    batch.update(currentUserFriendRef, {
      'status': 'accepted',
      'acceptedAt': FieldValue.serverTimestamp(),
    });

    // Update friend's status to accepted (they sent the request, so it was "requested")
    final friendUserFriendRef = _firestore
        .collection('users')
        .doc(friend.id)
        .collection('friends')
        .doc(user.uid);

    batch.update(friendUserFriendRef, {
      'status': 'accepted',
      'acceptedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  // Decline a friend request
  Future<void> declineFriendRequest(Friend friend) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final batch = _firestore.batch();

    // Remove from current user's friends collection
    final currentUserFriendRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('friends')
        .doc(friend.id);

    batch.delete(currentUserFriendRef);

    // Remove from friend's friends collection
    final friendUserFriendRef = _firestore
        .collection('users')
        .doc(friend.id)
        .collection('friends')
        .doc(user.uid);

    batch.delete(friendUserFriendRef);

    await batch.commit();
  }

  // Remove/Unfriend someone
  Future<void> removeFriend(Friend friend) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final batch = _firestore.batch();

    // Remove from current user's friends collection
    final currentUserFriendRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('friends')
        .doc(friend.id);

    batch.delete(currentUserFriendRef);

    // Remove from friend's friends collection
    final friendUserFriendRef = _firestore
        .collection('users')
        .doc(friend.id)
        .collection('friends')
        .doc(user.uid);

    batch.delete(friendUserFriendRef);

    await batch.commit();
  }

  // Cancel a sent friend request
  Future<void> cancelFriendRequest(Friend friend) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final batch = _firestore.batch();

    // Remove from current user's friends collection
    final currentUserFriendRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('friends')
        .doc(friend.id);

    batch.delete(currentUserFriendRef);

    // Remove from friend's friends collection
    final friendUserFriendRef = _firestore
        .collection('users')
        .doc(friend.id)
        .collection('friends')
        .doc(user.uid);

    batch.delete(friendUserFriendRef);

    await batch.commit();
  }

  // Get all friends with different statuses
  Future<List<Friend>> getFriends() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    final snapshot =
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('friends')
            .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Friend(
        id: data['id'] ?? doc.id,
        name: data['name'] ?? 'Unknown',
        status: _stringToFriendStatus(data['status'] ?? 'pending'),
      );
    }).toList();
  }

  // Check if friendship exists and what status
  Future<FriendStatus?> getFriendshipStatus(String friendId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final doc =
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('friends')
            .doc(friendId)
            .get();

    if (!doc.exists) return null;

    final status = doc.data()?['status'];
    return _stringToFriendStatus(status);
  }

  // Search for users to add as friends
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    // Search by username (you might want to add more search criteria)
    final querySnapshot =
        await _firestore
            .collection('users')
            .where('userName', isEqualTo: query)
            .limit(10)
            .get();

    return querySnapshot.docs
        .where((doc) => doc.id != user.uid) // Exclude current user
        .map(
          (doc) => {
            'id': doc.id,
            'userName': doc.data()['userName'] ?? 'Unknown',
          },
        )
        .toList();
  }

  // Helper function to convert string to FriendStatus enum
  FriendStatus _stringToFriendStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'accepted':
        return FriendStatus.accepted;
      case 'pending':
        return FriendStatus.pending;
      case 'requested':
        return FriendStatus.requested;
      default:
        return FriendStatus.pending;
    }
  }

  // ===== Shared Database ===== //

  // Save entry to the appropriate collection
  Future<void> saveEntry(MediaEntry entry) async {
    // Determine the collection name from the media type
    String collectionName;
    switch (entry.mediaType) {
      case MediaType.game:
        collectionName = 'games';
        break;
      case MediaType.movie:
        collectionName = 'movies';
        break;
      case MediaType.show:
        collectionName = 'shows';
        break;
    }

    // Set the document with the entry's ID in the correct collection
    await _firestore
        .collection(collectionName)
        .doc(entry.id)
        .set(entry.toMap());
  }

  // Load a single entry from its specific document
  Future<MediaEntry?> loadEntry(String type, String id) async {
    // Use the new, more descriptive type string like 'games'
    final doc = await _firestore.collection(type).doc(id).get();

    if (!doc.exists || doc.data() == null) {
      return null;
    }

    final entryData = doc.data()!;

    // The 'type' parameter should now be 'games', 'movies', etc.
    switch (type) {
      case 'games':
        return Game.fromMap(entryData);
      case 'shows':
        return Show.fromMap(entryData);
      case 'movies':
        return Movie.fromMap(entryData);
      default:
        return null;
    }
  }

  Future<Map<String, Game>> loadMultipleGames(List<String> ids) async {
    if (ids.isEmpty) return {};

    final Map<String, Game> foundGames = {};

    // Firestore's 'whereIn' query is limited to 30 elements per query.
    // We need to break our list of IDs into chunks of 30.
    for (var i = 0; i < ids.length; i += 30) {
      final chunk = ids.sublist(i, i + 30 > ids.length ? ids.length : i + 30);

      // This is the optimized query. It makes ONE network request for each chunk.
      final querySnapshot =
          await _firestore
              .collection('games')
              .where(FieldPath.documentId, whereIn: chunk)
              .get();

      for (final doc in querySnapshot.docs) {
        if (doc.exists) {
          foundGames[doc.id] = Game.fromMap(doc.data());
        }
      }
    }

    return foundGames;
  }
}
