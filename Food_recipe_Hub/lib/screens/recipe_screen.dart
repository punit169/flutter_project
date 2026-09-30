import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/recipe_provider.dart';
import '../providers/bookmark_provider.dart';
import '../models/recipe.dart';
import 'recipe_detail_screen.dart';
import 'bookmark_list_screen.dart';
import '../providers/like_provider.dart';

class RecipesScreen extends ConsumerStatefulWidget {
  const RecipesScreen({super.key, this.initialQuery});
  final String? initialQuery;

  @override
  ConsumerState<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends ConsumerState<RecipesScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.initialQuery != null) {
      Future.microtask(() {
        ref.read(recipesProvider.notifier).search(widget.initialQuery!);
      });
    }

    _scrollController.addListener(() {
      final position = _scrollController.position;

      // ─────────────────────────────────────────────────────
      // FIX 1: Guard against firing when already loading
      // Before: listener fired continuously near the bottom,
      // calling loadMore() dozens of times per second.
      // The _isLoading flag inside the notifier blocked
      // duplicate API calls but wasted CPU checking every frame.
      //
      // Now: we check isLoading from STATE (visible to UI)
      // before even calling loadMore() — clean and efficient.
      // ─────────────────────────────────────────────────────
      final isLoading = ref.read(recipesProvider).isLoading;

      if (!isLoading &&
          position.pixels >= position.maxScrollExtent - 200) {
        ref.read(recipesProvider.notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ─────────────────────────────────────────────────────
    // FIX 2: Watch RecipeState object (not just List<Recipe>)
    // This gives us BOTH recipes and isLoading in one watch call.
    // When isLoading changes, this widget rebuilds automatically
    // and shows/hides the spinner at the bottom.
    // ─────────────────────────────────────────────────────
    final recipeState = ref.watch(recipesProvider);
    final recipes = recipeState.recipes;
    final isLoading = recipeState.isLoading;

    final favorites = ref.watch(favoritesProvider);
    final likedIds = ref.watch(likeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Recipes"),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark, color: Colors.blueAccent),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FavoritesListScreen()),
              );
            },
          ),
        ],
      ),

      body: Column(
        children: [

          // Search Bar
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search recipes...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    ref.read(recipesProvider.notifier).loadRecipes();
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onSubmitted: (value) {
                ref.read(recipesProvider.notifier).search(value);
              },
            ),
          ),

          // Recipe List
          Expanded(
            child: recipes.isEmpty && isLoading
            // ─────────────────────────────────────────
            // Initial load: list is empty AND loading
            // Show a full-screen spinner (first page load)
            // ─────────────────────────────────────────
                ? const Center(child: CircularProgressIndicator())

                : ListView.builder(
              controller: _scrollController,

              // ─────────────────────────────────────
              // FIX 3: itemCount = recipes + 1 extra slot
              // The extra slot at the end is used to show
              // the loading spinner while more recipes load.
              //
              // WHY +1: ListView.builder needs to know how
              // many items to render. We add one extra item
              // at the bottom that renders the spinner
              // conditionally. When not loading, it renders
              // nothing (SizedBox.shrink).
              // ─────────────────────────────────────
              itemCount: recipes.length + (isLoading ? 1 : 0),

              itemBuilder: (context, index) {

                // Last item = loading spinner
                if (index == recipes.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                // Normal recipe tile
                final Recipe recipe = recipes[index];
                final isFav = favorites.contains(recipe.id);
                final isLiked = likedIds.contains(recipe.id);

                return ListTile(
                  leading: Image.network(
                    recipe.image,
                    width: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                    const Icon(Icons.image_not_supported),
                  ),

                  title: Text(recipe.title),

                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          isFav ? Icons.bookmark : Icons.bookmark_border,
                          color: Colors.blue,
                        ),
                        onPressed: () {
                          ref
                              .read(favoritesProvider.notifier)
                              .toggleFavorite(recipe.id);
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          isLiked ? Icons.favorite : Icons.favorite_border,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          ref.read(likeProvider.notifier).toggleLike(recipe.id);
                        },
                      ),
                    ],
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
            ),
          ),
        ],
      ),
    );
  }
}