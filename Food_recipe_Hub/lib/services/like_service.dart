import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LikeService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get userId => _auth.currentUser!.uid;

  // 🔥 Toggle Like
  Future<void> toggleLike(int recipeId) async {
    final doc = _db.collection("users").doc(userId);

    final snapshot = await doc.get();
    final data = snapshot.data();

    List liked = data?["likedRecipes"] ?? [];

    if (liked.contains(recipeId)) {
      liked.remove(recipeId);
    } else {
      liked.add(recipeId);
    }

    await doc.update({
      "likedRecipes": liked,
    });
  }

  // 📥 Get liked recipes
  Future<List<int>> getLikedRecipes() async {
    final doc = await _db.collection("users").doc(userId).get();
    final data = doc.data();

    return List<int>.from(data?["likedRecipes"] ?? []);
  }

}