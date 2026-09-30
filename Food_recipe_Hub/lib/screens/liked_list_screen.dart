import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/like_provider.dart';
import '../providers/recipe_repository_provider.dart';
import '../models/recipe.dart';
import 'recipe_detail_screen.dart';

// ─────────────────────────────────────────────────────────────
// NEW SCREEN: Shows all recipes the user has liked
//
// WHY this screen didn't exist before:
// likeProvider only stored a List<int> of recipe IDs.
// The IDs are enough to show counts on the profile, but to
// show a full list with images and titles we need to fetch
// the actual recipe data from the API.
//
// We use getRecipesByIds() (bulk API — Fix 2) to fetch all
// liked recipes in ONE request instead of N sequential calls.
// ─────────────────────────────────────────────────────────────
class LikedListScreen extends ConsumerWidget {
  const LikedListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Read liked recipe IDs from likeProvider
    final likedIds = ref.watch(likeProvider);

    if (likedIds.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("Liked Recipes")),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.favorite_border, size: 60, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                "No liked recipes yet",
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                "Tap ❤️ on any recipe to like it",
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Liked Recipes (${likedIds.length})"),
      ),
      body: FutureBuilder<List<Recipe>>(
        // ✅ Bulk API — fetches ALL liked recipes in one request
        // WHY ref.read not ref.watch here:
        // We only need the service instance, not a reactive
        // subscription. ref.read is correct for one-time reads
        // inside FutureBuilder — ref.watch would cause
        // unnecessary rebuilds on every provider change.
        future: ref
            .read(recipeApiServiceProvider)
            .getRecipesByIds(likedIds.map((e) => e.toString()).toList()),

        builder: (context, snapshot) {
          // Loading — shimmer placeholders matching expected count
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ListView.builder(
              itemCount: likedIds.length,
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

              // Watch likeProvider to keep heart icon in sync
              // if user unlikes a recipe from this screen
              final isLiked = ref.watch(likeProvider).contains(recipe.id);

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
                  // ─────────────────────────────────────
                  // WHY allow unlike from this screen:
                  // Better UX — user might want to clean up
                  // their liked list. The icon updates instantly
                  // via optimistic UI (likeProvider updates state
                  // before Firestore confirms) so no lag.
                  // ─────────────────────────────────────
                  icon: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: Colors.red,
                  ),
                  onPressed: () {
                    ref.read(likeProvider.notifier).toggleLike(recipe.id);
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
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
      ),
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