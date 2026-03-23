import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class AuthService {
  final _auth = FirebaseAuth.instance;

  Future<User?> signUp(String email, String password) async {
    final result = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return result.user;
  }

  Future<User?> login(String email, String password) async {
    final result = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return result.user;
  }
  Future<void> saveUser(User user) async {
    final db = FirebaseFirestore.instance;

    await db.collection("users").doc(user.uid).set({
      "email": user.email,
      "createdAt": DateTime.now(),
      "likedRecipes": [],
    });
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}