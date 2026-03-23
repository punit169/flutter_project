import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LikeService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get userId => _auth.currentUser!.uid;

  // 🔥 Toggle Like
  Future<void> toggleLike(int recipeId) async {
    final userDoc = _db.collection("users").doc(userId);
    final likeDoc = _db.collection("likes").doc(recipeId.toString());

    final snapshot = await userDoc.get();
    List liked = snapshot.data()?["likedRecipes"] ?? [];

    bool isLiked = liked.contains(recipeId);

    if (isLiked) {
      liked.remove(recipeId);

      await likeDoc.set({
        "count": FieldValue.increment(-1),
      }, SetOptions(merge: true));
    } else {
      liked.add(recipeId);

      await likeDoc.set({
        "count": FieldValue.increment(1),
      }, SetOptions(merge: true));
    }

    await userDoc.update({
      "likedRecipes": liked,
    });
  }
  Future<List<int>> getTrendingRecipeIds() async {
    final snapshot = await _db
        .collection("likes")
        .orderBy("count", descending: true)
        .limit(10)
        .get();

    return snapshot.docs.map((doc) => int.parse(doc.id)).toList();
  }


  // 📥 Get liked recipes
  Future<List<int>> getLikedRecipes() async {
    final doc = await _db.collection("users").doc(userId).get();
    final data = doc.data();

    return List<int>.from(data?["likedRecipes"] ?? []);
  }

}