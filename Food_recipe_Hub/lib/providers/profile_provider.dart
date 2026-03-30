import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final profileProvider = Provider((ref) => ProfileService());

class ProfileService {
  final _picker = ImagePicker();
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  // 🔥 LOCAL IMAGE PICK (NO STORAGE)
  Future<String?> pickImageLocal() async {
    final file = await _picker.pickImage(source: ImageSource.gallery);

    if (file == null) return null;

    final user = _auth.currentUser;
    if (user == null) return null;

    final path = file.path;

    // 🔥 Save local path in Firestore
    await _db.collection("users").doc(user.uid).set({
      "photoPath": path,
    }, SetOptions(merge: true));

    return path;
  }
}