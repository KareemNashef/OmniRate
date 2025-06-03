import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:omnirate/Shared/user_data.dart';

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
    if (user == null) throw Exception('No user signed in');

    final doc = await _firestore.collection('users').doc(user.uid).get();

    if (!doc.exists) return null;

    return UserData.fromMap(doc.data()!);
  }
}
