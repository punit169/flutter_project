import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/legacy.dart';

final favoritesProvider =
StateNotifierProvider<FavoritesNotifier, Set<int>>((ref) {
  return FavoritesNotifier(ref);
});

class FavoritesNotifier extends StateNotifier<Set<int>> {
  final Ref ref;

  FavoritesNotifier(this.ref) : super({}) {
    loadFavorites();
  }

  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get userId => _auth.currentUser!.uid;

  // 🔄 LOAD (SAFE FOR OLD USERS)
  Future<void> loadFavorites() async {
    try {
      final doc =
      await _db.collection("users").doc(userId).get();

      final data = doc.data();
      if (data == null || !data.containsKey("bookmarks")) {
        await _db.collection("users").doc(userId).update({
          "bookmarks": [],
        });

        state = {};
        return;
      }
      // ✅ SAFE FALLBACK
      final favs = List<int>.from(data?["bookmarks"] ?? []);

      state = favs.toSet();
    } catch (e) {
      print("LOAD BOOKMARK ERROR: $e");
    }
  }

  // ❤️ TOGGLE
  Future<void> toggleFavorite(int recipeId) async {
    final newSet = {...state};

    if (newSet.contains(recipeId)) {
      newSet.remove(recipeId);
    } else {
      newSet.add(recipeId);
    }

    state = newSet; // instant UI update

    try {
      await _db.collection("users").doc(userId).update({
        "bookmarks": newSet.toList(),
      });
    } catch (e) {
      print("SAVE BOOKMARK ERROR: $e");
    }
  }
}