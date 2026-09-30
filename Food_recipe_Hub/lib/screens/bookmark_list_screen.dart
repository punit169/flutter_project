import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/bookmark_provider.dart';
import '../providers/recipe_repository_provider.dart';
import '../models/recipe.dart';
import 'recipe_detail_screen.dart';

// ─────────────────────────────────────────────────────────────
// UPDATED: Now uses RecipeApiService.getRecipesByIds() which
// calls the /informationBulk endpoint — one API call for all
// bookmarks instead of N sequential calls (Fix 2 applied here)
// ─────────────────────────────────────────────────────────────
class FavoritesListScreen extends ConsumerWidget {
  const FavoritesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriteIds = ref.watch(favoritesProvider).toList();

    if (favoriteIds.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("Bookmarks")),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bookmark_border, size: 60, color: Colors.grey),
              SizedBox(height: 16),
              Text("No bookmarks yet",
                  style: TextStyle(color: Colors.grey, fontSize: 16)),
              SizedBox(height: 8),
              Text("Tap 🔖 on any recipe to save it",
                  style: TextStyle(color: Colors.grey, fontSize: 13)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Bookmarks (${favoriteIds.length})"),
      ),
      body: FutureBuilder<List<Recipe>>(
        // ✅ Using bulk API — one request for all bookmark IDs
        future: ref
            .read(recipeApiServiceProvider)
            .getRecipesByIds(favoriteIds.map((e) => e.toString()).toList()),
        builder: (context, snapshot) {
          // Loading — show shimmer tiles
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ListView.builder(
              itemCount: favoriteIds.length,
              itemBuilder: (_, __) => const _ShimmerTile(),
            );
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final recipes = snapshot.data ?? [];

          return ListView.builder(
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final recipe = recipes[index];
              return ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    recipe.image,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                    const Icon(Icons.image_not_supported),
                  ),
                ),
                title: Text(recipe.title),
                trailing: IconButton(
                  icon: Icon(
                    ref.watch(favoritesProvider).contains(recipe.id)
                        ? Icons.bookmark
                        : Icons.bookmark_border,
                    color: Colors.blue,
                  ),
                  onPressed: () {
                    ref
                        .read(favoritesProvider.notifier)
                        .toggleFavorite(recipe.id);
                  },
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RecipeDetailScreen(recipe: recipe),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _ShimmerTile extends StatelessWidget {
  const _ShimmerTile();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
          width: 60, height: 60,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
          )),
      title: Container(
          height: 12,
          margin: const EdgeInsets.only(right: 80),
          color: Colors.grey[300]),
      subtitle: Container(
          height: 10,
          margin: const EdgeInsets.only(right: 120),
          color: Colors.grey[200]),
    );
  }
}