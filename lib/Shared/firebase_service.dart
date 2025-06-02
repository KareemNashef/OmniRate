import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {

  // Initialize services
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ===== Authentication ===== //

  // Sign in
  Future<User?> signIn(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
    return cred.user;
  }

  // Sign up
  Future<User?> signUp(String email, String password, String username) async {
    final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    final user = cred.user;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).set({'username': username, 'email': email});
    }
    return user;
  }

  // Sign out
  Future<void> signOut() async => _auth.signOut();

  // ===== Lists ===== //

  // Save or override a list
  Future<void> saveList(String listName, Map<String, String> listData) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user signed in');

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('lists')
        .doc(listName)
        .set(listData);
  }

  // Get a list by name
  Future<Map<String, String>?> getList(String listName) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user signed in');

    final doc = await _firestore.collection('users').doc(user.uid).collection('lists').doc(listName).get();
    if (!doc.exists) return null;

    final data = doc.data();
    return data?.map((key, value) => MapEntry(key, value.toString()));
  }
}
