import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/spoonacular_service.dart';
import '../providers/favorite_provider.dart';
import '../providers/recipe_provider.dart';
import '../models/recipe.dart';
import 'recipe_detail_screen.dart';

class FavoritesListScreen extends ConsumerWidget {
  const FavoritesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final favoriteIds = ref.watch(favoritesProvider).toList();
    final recipes = ref.watch(recipesProvider);

    final favoriteRecipes = recipes
        .where((r) => favoriteIds.contains(r.id.toString()))
        .toList();

    Future<List<Recipe>> fetchFavorites() async {
      final service = SpoonacularService();

      List<Recipe> recipes = [];

      for (var id in favoriteIds) {
        final recipe = await service.fetchRecipeDetails(int.parse(id));
        recipes.add(recipe);
      }

      return recipes;
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bookmarks"),
      ),

      body: favoriteRecipes.isEmpty
          ? const Center(
        child: Text("No Bookmarks yet"),
      )
          : FutureBuilder<List<Recipe>>(
        future: fetchFavorites(),
        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 5,
                itemBuilder: (_, __) => const ShimmerCard(),
              ),
            );
          }

          final favorites = snapshot.data!;

          if (favorites.isEmpty) {
            return const Center(child: Text("No Bookmarks yet"));
          }

          return ListView.builder(
            itemCount: favorites.length,
            itemBuilder: (context, index) {

              final recipe = favorites[index];

              return ListTile(
                leading: Image.network(recipe.image, width: 60),
                title: Text(recipe.title),
                trailing: const Icon(
                  Icons.bookmark,
                  color: Colors.blue,
                ),

                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          RecipeDetailScreen(recipe: recipe),
                    ),
                  );
                },
              );
            },
          );
        },
      )
    );
  }
}
class ShimmerCard extends StatelessWidget {
  const ShimmerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(left: 16),
      child: Column(
        children: [
          Container(
            height: 120,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 8),
          Container(
            height: 10,
            color: Colors.grey[300],
          ),
        ],
      ),
    );
  }
}