import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_recipe_hub/models/recipe.dart';
import '../providers/like_provider.dart';
import '../widgets/explore_widgets.dart';
import '../widgets/list_widgets.dart';
import '../providers/bookmark_provider.dart';
import '../providers/recipe_repository_provider.dart';
class ExploreScreen extends ConsumerWidget {
  const ExploreScreen({super.key});


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final api = ref.read(recipeApiServiceProvider);
    final likeService = ref.read(likeServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Explore"),
        centerTitle: true,
      ),
      body: FutureBuilder<List<int>>(
        future: likeService.getTrendingRecipeIds(),
        builder: (context, trendingIdSnap) {
          if (!trendingIdSnap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final trendingIds = trendingIdSnap.data!;

          return FutureBuilder<List<Recipe>>(
            future: trendingIds.isEmpty
                ? api.getTrendingRecipes()
                : api.getRecipesByIds(
              trendingIds.map((e) => e.toString()).toList(),
            ),
            builder: (context, trendingSnap) {
              if (!trendingSnap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final trending = trendingSnap.data!;

              return FutureBuilder<List<List<Recipe>>>(
                future: Future.wait([
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

                  final healthy = snapshot.data![0];
                  final quick = snapshot.data![1];

                  final favoriteIds =
                  ref.watch(favoritesProvider).toList();

                  return FutureBuilder(
                    future: api.getRecipesByIds(favoriteIds),
                    builder: (context, favSnapshot) {
                      final favoritesRecipes =
                          favSnapshot.data as List<Recipe>? ?? [];

                      return SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const ExploreSearchBar(),

                            SectionTitle(title: "🥗 Categories"),
                            const CategoryList(),

                            const SizedBox(height: 20),

                            // 🔥 REAL TRENDING
                            SectionTitle(title: "🔥 Trending"),
                            TrendingRecipesList(recipes: trending),

                            if (favoritesRecipes.isNotEmpty) ...[
                              const SectionTitle(
                                  title: "❤️ Based on Bookmarks"),
                              TrendingRecipesList(
                                  recipes: favoritesRecipes),
                            ] else ...[
                              const Padding(
                                padding: EdgeInsets.all(16),
                                child: Text(
                                  "Add bookmarks to get recommendations",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                            ],

                            SectionTitle(title: "🥗 Healthy"),
                            TrendingRecipesList(recipes: healthy),

                            SectionTitle(title: "⚡ Quick Meals"),
                            TrendingRecipesList(recipes: quick),
                          ],
                        ),
                      );
                    },
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