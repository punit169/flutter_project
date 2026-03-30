import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final profileControllerProvider =
StateNotifierProvider<ProfileController, AsyncValue<String?>>(
      (ref) => ProfileController(),
);

class ProfileController extends StateNotifier<AsyncValue<String?>> {
  ProfileController() : super(const AsyncData(null));

  final _picker = ImagePicker();
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;
  Future<void> updateUsername(String username) async {
    final user = _auth.currentUser;
    if (user == null) return;

    state = const AsyncLoading();

    try {

      await _db.collection("users").doc(user.uid).update({
        "username": username,
      });

      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
  Future<void> pickImage() async {
    try {
      state = const AsyncLoading();

      final file = await _picker.pickImage(source: ImageSource.gallery);
      if (file == null) {
        state = const AsyncData(null);
        return;
      }

      final user = _auth.currentUser;
      if (user == null) throw Exception("User not logged in");

      final path = file.path;

      await _db.collection("users").doc(user.uid).set({
        "photoPath": path,
      }, SetOptions(merge: true));

      state = AsyncData(path); // ✅ success
    } catch (e) {
      state = AsyncError(e, StackTrace.current); // ❌ error
    }
  }
}