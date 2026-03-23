import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/like_service.dart';

final likeProvider =
StateNotifierProvider<LikeNotifier, List<int>>((ref) {
  return LikeNotifier();
});

class LikeNotifier extends StateNotifier<List<int>> {
  LikeNotifier() : super([]) {
    loadLikes();
  }

  final likeService = LikeService();

  // 🔥 Load liked recipes
  Future<void> loadLikes() async {
    final likes = await likeService.getLikedRecipes();
    state = likes;
  }

  // ❤️ Toggle like
  Future<void> toggleLike(int recipeId) async {
    await likeService.toggleLike(recipeId);

    if (state.contains(recipeId)) {
      state = state.where((id) => id != recipeId).toList();
    } else {
      state = [...state, recipeId];
    }
  }
}