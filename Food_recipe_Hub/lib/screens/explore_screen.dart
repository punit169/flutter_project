import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_recipe_hub/models/recipe.dart';
import '../widgets/explore_widgets.dart';
import '../widgets/list_widgets.dart';
import '../providers/favorite_provider.dart';
import '../providers/recipe_repository_provider.dart';
class ExploreScreen extends ConsumerWidget {
  const ExploreScreen({super.key});


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final api = ref.read(recipeApiServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Explore"),
        centerTitle: true,
      ),
      body: FutureBuilder<List<List<Recipe>>>(
        future: Future.wait<List<Recipe>>([
          api.getTrendingRecipes(),
          api.getHealthyRecipes(),
          api.getQuickRecipes(),
        ]),
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

          final trending = snapshot.data![0] ;
          final healthy = snapshot.data![1];
          final quick = snapshot.data![2];

          final favoriteIds = ref.watch(favoritesProvider).toList();
          return FutureBuilder(
            future: api.getRecipesByIds(favoriteIds),
            builder: (context, favSnapshot) {
              final favoritesRecipes = favSnapshot.data as List<Recipe>? ?? [];

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ExploreSearchBar(),
                    SectionTitle(title: "🥗 Categories"),
                    CategoryList(),

                    SizedBox(height: 20),
                    SectionTitle(title: "🔥 For You"),
                    TrendingRecipesList(recipes: trending),

                    if (favoritesRecipes.isNotEmpty) ...[
                      SectionTitle(title: "❤️ Based on Favorites"),
                      TrendingRecipesList(recipes: favoritesRecipes),
                    ] else ...[
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "❤️ Based on Favorites",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Add favorites to get personalized recommendations",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],


                    SectionTitle(title: "⚡ Quick Meals"),
                    TrendingRecipesList(recipes: quick),
                  ],
                ),
              );
            },
          );
        },
      ),
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