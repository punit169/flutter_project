import 'dart:io';
import 'dart:convert'; // ✅ For base64Encode
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

      // Pick image with aggressive compression
      // WHY low quality (40)? Base64 increases file size by ~33%.
      // A 1MB photo becomes ~1.3MB string in Firestore.
      // Firestore document limit is 1MB, so we need to compress hard.
      // At quality 40, a typical photo becomes ~50-80KB → safe to store.
      final file = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 40,   // compress aggressively for Firestore storage
        maxWidth: 300,      // profile photos don't need to be large
        maxHeight: 300,
      );

      if (file == null) {
        state = const AsyncData(null);
        return;
      }

      final user = _auth.currentUser;
      if (user == null) throw Exception("User not logged in");

      // ✅ FREE ALTERNATIVE TO FIREBASE STORAGE:
      // Read image bytes → encode to Base64 string → save in Firestore
      //
      // WHY Base64? Firestore only stores text/numbers, not binary files.
      // Base64 converts binary image bytes into a plain text string that
      // Firestore can store. On display, we decode it back to bytes and
      // render with MemoryImage.
      //
      // TRADE-OFF (important for interviews):
      // Base64 increases size by ~33%. Suitable ONLY for small images like
      // profile photos. For large media, Firebase Storage or Cloudinary
      // is the correct solution — but those require paid plans.
      final bytes = await File(file.path).readAsBytes();
      final base64String = base64Encode(bytes);

      // Save the base64 string to Firestore under the user's document
      await _db.collection("users").doc(user.uid).set({
        "photoPath": base64String,
      }, SetOptions(merge: true));

      state = AsyncData(base64String);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }
}