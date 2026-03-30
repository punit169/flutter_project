import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../services/like_service.dart';
import 'auth_provider.dart';
final likeServiceProvider = Provider<LikeService>((ref) {
  return LikeService();
});
final likeProvider =
StateNotifierProvider<LikeNotifier, List<int>>((ref) {
  final auth = ref.watch(firebaseAuthProvider);

  return auth.when(
    data: (_) => LikeNotifier(),
    loading: () => LikeNotifier(),
    error: (_, __) => LikeNotifier(),
  );
});

class LikeNotifier extends StateNotifier<List<int>> {
  LikeNotifier() : super([]) {
    loadLikes();
  }

  final likeService = LikeService();

  // Load liked recipes
  Future<void> loadLikes() async {
    try {
      state = []; // clear old state

      final likes = await likeService.getLikedRecipes();
      state = likes;
    } catch (e) {
      state = [];
    }
  }

  // Toggle like
  Future<void> toggleLike(int recipeId) async {
    try {
      await likeService.toggleLike(recipeId);

      if (state.contains(recipeId)) {
        state = state.where((id) => id != recipeId).toList();
      } else {
        state = [...state, recipeId];
      }
    } catch (e) {
      // optional: handle error
    }
  }
}