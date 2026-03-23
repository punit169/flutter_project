import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_recipe_hub/models/recipe.dart';
import '../providers/like_provider.dart';
import '../widgets/explore_widgets.dart';
import '../widgets/list_widgets.dart';
import '../providers/bookmark_provider.dart';
import '../providers/recipe_repository_provider.dart';
import '../screens/profile_screen.dart';
import '../providers/user_provider.dart';

class ExploreScreen extends ConsumerWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final api = ref.read(recipeApiServiceProvider);
    final likeService = ref.read(likeServiceProvider);
    final user = ref.read(userProvider);
    final likedIds = ref.watch(likeProvider);
    final bookmarkIds = ref.watch(favoritesProvider);

    final combined = [...likedIds, ...bookmarkIds];
    final userAsync = ref.read(userProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Explore"),
        centerTitle: true,
        actions: [
          userAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.only(right: 12),
              child: CircleAvatar(
                radius: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),

            error: (e, _) => const Icon(Icons.error),

            data: (user) {
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ProfileScreen(),
                      ),
                    );
                  },
                  child: CircleAvatar(
                    radius: 18,
                    backgroundImage: user?.photoUrl != null
                        ? NetworkImage(user!.photoUrl!)
                        : null,
                    child: user?.photoUrl == null
                        ? const Icon(Icons.person)
                        : null,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<int>>(
        future: likeService.getTrendingRecipeIds(),
        builder: (context, trendingIdSnap) {
          if (!trendingIdSnap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final trendingIds = trendingIdSnap.data!;

          return FutureBuilder<List<Recipe>>(
            future:  () async {
              final likedIds = ref.read(likeProvider);
              final bookmarkIds = ref.read(favoritesProvider).toList();

              final combined = [...likedIds, ...bookmarkIds];

              // fallback if empty
              if (combined.isEmpty) {
                return await api.getTrendingRecipes();
              }

              final sample = await api.getRecipesByIds(
                combined.take(1).map((e) => e.toString()).toList(),
              );

              final query =
              sample.isNotEmpty ? sample.first.title : "food";

              final recommended =
              await api.getRecommendedRecipes(query);

              return recommended;
            }(),
            builder: (context, recSnapshot) {
              if (!recSnapshot.hasData) {
                return const SizedBox();
              }

              final recommended = recSnapshot.data!;

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

                            const SectionTitle(title: "🔥 Trending" ),
                            TrendingRecipesList(recipes: recommended),


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