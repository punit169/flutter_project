import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final commentActionsProvider = Provider((ref) {
  return CommentActions();
});

class CommentActions {
  final _db = FirebaseFirestore.instance;

  // ❤️ Like comment
  Future<void> toggleLikeComment(
      int recipeId, String commentId, String userId) async {
    final doc = _db
        .collection("comments")
        .doc(recipeId.toString())
        .collection("items")
        .doc(commentId);

    final snapshot = await doc.get();
    final data = snapshot.data();

    List likedBy = data?["likedBy"] ?? [];

    if (likedBy.contains(userId)) {
      // 👎 UNLIKE
      likedBy.remove(userId);

      await doc.update({
        "likes": FieldValue.increment(-1),
        "likedBy": likedBy,
      });
    } else {
      // 👍 LIKE
      likedBy.add(userId);

      await doc.update({
        "likes": FieldValue.increment(1),
        "likedBy": likedBy,
      });
    }
  }

  // 🗑 Delete comment
  Future<void> deleteComment(int recipeId, String commentId) async {
    await _db
        .collection("comments")
        .doc(recipeId.toString())
        .collection("items")
        .doc(commentId)
        .delete();
  }
}