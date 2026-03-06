import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/favorite_provider.dart';
import '../providers/recipe_provider.dart';
import '../models/recipe.dart';
import 'recipe_detail_screen.dart';

class FavoritesListScreen extends ConsumerWidget {
  const FavoritesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final favoriteIds = ref.watch(favoritesProvider);
    final recipes = ref.watch(recipesProvider);

    final favoriteRecipes = recipes
        .where((r) => favoriteIds.contains(r.id.toString()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Favorite Recipes"),
      ),

      body: favoriteRecipes.isEmpty
          ? const Center(
        child: Text("No favorite recipes yet"),
      )
          : ListView.builder(
        itemCount: favoriteRecipes.length,
        itemBuilder: (context, index) {

          final Recipe recipe = favoriteRecipes[index];

          return ListTile(
            leading: Image.network(
              recipe.image,
              width: 60,
              errorBuilder: (_, __, ___) =>
              const Icon(Icons.image_not_supported),
            ),

            title: Text(recipe.title),

            trailing: const Icon(
              Icons.favorite,
              color: Colors.red,
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
      ),
    );
  }
}