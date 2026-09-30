import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/comment_model.dart';

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