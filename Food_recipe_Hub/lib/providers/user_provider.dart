import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

final userProvider = FutureProvider<AppUser?>((ref) async {
  final firebaseUser = FirebaseAuth.instance.currentUser;

  if (firebaseUser == null) return null;

  final doc = await FirebaseFirestore.instance
      .collection("users")
      .doc(firebaseUser.uid)
      .get();

  final data = doc.data();

  return AppUser(
    uid: firebaseUser.uid,
    email: firebaseUser.email ?? "",
    username: data?["username"] ?? "User",
    photoUrl: data?["photoUrl"],
  );
});