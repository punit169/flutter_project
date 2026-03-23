import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/comment_model.dart';
import 'user_provider.dart';

final commentsProvider =
StreamProvider.family<List<Comment>, int>((ref, recipeId) {
  final db = FirebaseFirestore.instance;

  return db
      .collection("comments")
      .doc(recipeId.toString())
      .collection("items")
      .orderBy("createdAt", descending: true)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs
        .map((doc) => Comment.fromJson(doc.data(), doc.id))
        .toList();
  });
});

class CommentsNotifier extends StateNotifier<List<Comment>> {
  final Ref ref;
  final int recipeId;

  final _db = FirebaseFirestore.instance;

  CommentsNotifier(this.ref, this.recipeId) : super([]) {
    loadComments();
  }

  // 📥 Load comments
  Future<void> loadComments() async {
    final snapshot = await _db
        .collection("comments")
        .doc(recipeId.toString())
        .collection("items")
        .orderBy("createdAt", descending: true)
        .get();

    state = snapshot.docs
        .map((doc) => Comment.fromJson(doc.data(), doc.id))
        .toList();
  }

  Future<void> addComment(String text) async {
    final user = await ref.read(userProvider.future);

    if (user == null) return;

    await _db
        .collection("comments")
        .doc(recipeId.toString())
        .collection("items")
        .add({
      "userId": user.uid,
      "username": user.username,
      "photoUrl": user.photoUrl, // 👈 NEW
      "text": text,
      "likes": 0, // 👈 NEW
      "createdAt": FieldValue.serverTimestamp(),
      "likedBy": [],
      "createdAt": FieldValue.serverTimestamp(),
    });
  }


}