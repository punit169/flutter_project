import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/recipe.dart';
import 'like_provider.dart';
import 'bookmark_provider.dart';
import 'recipe_repository_provider.dart';

// ─────────────────────────────────────────────────────────────
// WHY keepAlive() is still here:
// Without keepAlive(), every time the user navigates away from
// ExploreScreen and comes back, the FutureProvider disposes
// itself and re-fetches everything from scratch — wasting API
// quota and showing a full loading screen each time.
//
// With keepAlive(), data is cached in memory. The user can
// switch tabs and come back instantly with no reload.
//
// BUT the problem was: there was NO way to refresh at all.
// Fix: ref.invalidate(exploreDataProvider) from the UI forces
// the provider to dispose and re-run — giving us on-demand
// refresh while keeping the cache benefit for normal navigation.
// ─────────────────────────────────────────────────────────────
final exploreDataProvider = FutureProvider((ref) async {
  ref.keepAlive();

  final api = ref.read(recipeApiServiceProvider);
  final likeService = ref.read(likeServiceProvider);

  try {
    final trendingIds = await likeService.getTrendingRecipeIds();

    final futures = await Future.wait([
      trendingIds.isEmpty
          ? api.searchRecipes("popular")
          : api.getRecipesByIds(
        trendingIds.map((e) => e.toString()).toList(),
      ),
      api.getHealthyRecipes(),
      api.getQuickRecipes(),
    ]);

    final trending = futures[0];
    final healthy = futures[1];
    final quick = futures[2];

    final bookmarkIds =
    ref.read(favoritesProvider).map((e) => e.toString()).toList();

    final bookmarks = bookmarkIds.isEmpty
        ? <Recipe>[]
        : await api.getRecipesByIds(bookmarkIds);

    final likedIds =
    ref.read(likeProvider).map((e) => e.toString()).toList();

    final combined = [...likedIds, ...bookmarkIds];

    List<Recipe> recommended = [];

    if (combined.isNotEmpty) {
      final sample = await api.getRecipesByIds(
        combined.take(3).map((e) => e.toString()).toList(),
      );
      final words = <String>{};

      for (var r in sample) {
        words.addAll(r.title.toLowerCase().split(" ").take(2));
      }
      final query = words.take(3).join(" ");
      recommended = await api.getRecommendedRecipes(query);
    }

    return {
      "trending": trending,
      "healthy": healthy,
      "quick": quick,
      "bookmarks": bookmarks,
      "recommended": recommended,
    };
  } catch (e) {
    debugPrint("Explore ERROR: $e");
    rethrow;
  }
});