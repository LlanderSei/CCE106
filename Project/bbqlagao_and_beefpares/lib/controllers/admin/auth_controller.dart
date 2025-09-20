// lib/controllers/admin/auth_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/legacy.dart';

// Start modification: Added role check for admin after login
final authControllerProvider = StateNotifierProvider<AuthController, User?>((ref) {
  return AuthController(FirebaseAuth.instance, FirebaseFirestore.instance);
});

class AuthController extends StateNotifier<User?> {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthController(this._auth, this._firestore) : super(null) {
    _auth.authStateChanges().listen((user) {
      state = user;
    });
  }

  // Login method for admin
  Future<void> login(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
    final uid = credential.user!.uid;
    final userDoc = await _firestore.collection('users').doc(uid).get();
    print(userDoc);
    if (!userDoc.exists || userDoc.data()!['role'] != 'admin') {
      await _auth.signOut();
      throw Exception('User is not an admin');
    }
  }

  // Logout method
  Future<void> logout() async {
    await _auth.signOut();
    state = null;
  }
}
// End modification