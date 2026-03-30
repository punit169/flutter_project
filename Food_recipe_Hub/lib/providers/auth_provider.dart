import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/legacy.dart';

final authProvider =
StateNotifierProvider<AuthNotifier, User?>((ref) {
  return AuthNotifier();
});
final firebaseAuthProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});
class AuthNotifier extends StateNotifier<User?> {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  AuthNotifier() : super(null) {
    _auth.authStateChanges().listen((user) {
      state = user;
    });
  }

  // LOGIN
  Future<void> login(String email, String password) async {
    await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // SIGNUP
  Future<void> signup(
      String email, String password, String username) async {

    try {
      // 1. CREATE AUTH USER
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = result.user;

      if (user == null) {
        throw Exception("User creation failed");
      }

      // 2. SAVE USER DATA (NO UNIQUE CHECK)
      await _db.collection("users").doc(user.uid).set({
        "email": email,
        "username": username.isEmpty ? "User" : username,
        "photoPath": null,
        "likedRecipes": [],
        "bookmarks": [],
      });

    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw Exception("Email already exists");
      } else {
        throw Exception(e.message ?? "Signup failed");
      }
    }
  }

  // LOGOUT
  Future<void> logout() async {
    await _auth.signOut();
    // state = null;
  }
}