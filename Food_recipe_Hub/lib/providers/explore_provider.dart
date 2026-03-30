import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/recipe.dart';
import 'like_provider.dart';
import 'bookmark_provider.dart';
import 'recipe_repository_provider.dart';

final exploreDataProvider = FutureProvider((ref) async {
  ref.keepAlive();
  final api = ref.read(recipeApiServiceProvider);
  final likeService = ref.read(likeServiceProvider);

  try {
    final trendingIds = await likeService.getTrendingRecipeIds();

    final trending = trendingIds.isEmpty
        ? await api.getTrendingRecipeIds()
        : await api.getRecipesByIds(
      trendingIds.map((e) => e.toString()).toList(),
    );

    final healthy = await api.getHealthyRecipes();
    final quick = await api.getQuickRecipes();

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
    print("Explore ERROR: $e");
    throw e;
  }
});