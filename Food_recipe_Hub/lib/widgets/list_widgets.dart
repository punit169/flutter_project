import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/recipe_provider.dart';
import '../screens/recipe_screen.dart';
import '../screens/recipe_detail_screen.dart';
import '../models/recipe.dart';
import '../providers/like_provider.dart';

class TrendingRecipesList extends ConsumerWidget {
  final List<Recipe> recipes;

  const TrendingRecipesList({
    super.key,
    required this.recipes,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = recipes;

    if (list.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: list.length,
        itemBuilder: (context, index) {
          final recipe = list[index];

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RecipeDetailScreen(recipe: recipe),
                ),
              );
            },
            child: Container(
              width: 160,
              margin: const EdgeInsets.only(left: 16),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      recipe.image,
                      height: 180,
                      width: 160,
                      fit: BoxFit.cover,
                    ),
                  ),

                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.6),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),

                  Positioned(
                    bottom: 8,
                    left: 8,
                    right: 8,
                    child: Text(
                      recipe.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  Positioned(
                    top: 8,
                    right: 8,
                    child: Consumer(
                      builder: (context, ref, _) {
                        final likedIds = ref.watch(likeProvider);
                        final isLiked = likedIds.contains(recipe.id);

                        return IconButton(
                          icon: Icon(
                            isLiked
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            ref
                                .read(likeProvider.notifier)
                                .toggleLike(recipe.id);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
class CategoryList extends StatelessWidget {
  const CategoryList({super.key});

  final List<Map<String, String>> categories = const [
    {"name": "Quick", "query": "quick"},
    {"name": "Healthy", "query": "healthy"},
    {"name": "Veg", "query": "vegetarian"},
    {"name": "Dessert", "query": "dessert"},
    {"name": "Breakfast", "query": "breakfast"},
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RecipesScreen(
                    initialQuery: categories[index]["query"]!,
                  ),
                ),
              );
            },
            child: Container(
              width: 160,
              margin: const EdgeInsets.only(left: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(categories[index]["name"]!),
              ),
            ),
          );
        },
      ),
    );
  }
}
class RecommendedList extends ConsumerWidget {
  const RecommendedList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipes = ref.watch(recipesProvider);
    if (recipes.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          "Nothing here yet 👀",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: recipes.length,
      itemBuilder: (context, index) {
        final recipe = recipes[index];

        return ListTile(
          leading: Image.network(recipe.image, width: 60, fit: BoxFit.cover),
          title: Text(recipe.title),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => RecipeDetailScreen(recipe : recipe)
              )
            );
          },
        );
      },
    );
  }
}