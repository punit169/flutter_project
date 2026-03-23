import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final authProvider =
StateNotifierProvider<AuthNotifier, User?>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<User?> {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  AuthNotifier() : super(null) {
    state = _auth.currentUser;
  }

  // 🔐 LOGIN
  Future<void> login(String email, String password) async {
    final result = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    state = result.user;
  }

  // 🆕 SIGNUP (IMPORTANT)
  Future<void> signup(
      String email, String password, String username) async {
    final result = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = result.user;

    if (user != null) {
      // ✅ Save to Firestore
      await _db.collection("users").doc(user.uid).set({
        "email": email,
        "username": username,
        "photoUrl": null,
        "likedRecipes": [],
      });
    }

    state = user;
  }

  // 🚪 LOGOUT
  Future<void> logout() async {
    await _auth.signOut();
    state = null;
  }
}