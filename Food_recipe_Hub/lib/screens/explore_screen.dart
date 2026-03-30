import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_recipe_hub/models/recipe.dart';
import '../providers/like_provider.dart';
import '../widgets/explore_widgets.dart';
import '../widgets/list_widgets.dart';
import '../providers/bookmark_provider.dart';
import '../providers/recipe_repository_provider.dart';
import '../screens/profile_screen.dart';
import '../providers/user_provider.dart';
import '../providers/explore_provider.dart';

class ExploreScreen extends ConsumerWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final api = ref.read(recipeApiServiceProvider);
    final exploreAsync = ref.watch(exploreDataProvider);

    final likeService = ref.read(likeServiceProvider);
    final user = ref.read(userProvider);
    final likedIds = ref.watch(likeProvider);
    final bookmarkIds = ref.watch(favoritesProvider);
    ImageProvider imageProvider;
    ImageProvider getProfileImage(user) {
      if (user?.photoPath != null &&
          File(user.photoPath!).existsSync()) {
        return FileImage(File(user.photoPath!));
      } else {
        return NetworkImage(
          "https://ui-avatars.com/api/?name=${user?.username ?? "User"}&background=ff9800&color=fff",
        );
      }
    }
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
                    radius: 20,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: getProfileImage(user),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: exploreAsync.when(
        loading: () =>
        const Center(child: CircularProgressIndicator()),

        error: (e, _) =>
            Center(child: Text("Error: $e")),

        data: (data) {
          final trending = data["trending"] as List<Recipe>;
          final healthy = data["healthy"] as List<Recipe>;
          final quick = data["quick"] as List<Recipe>;
          final bookmarks = data["bookmarks"] as List<Recipe>;
          final recommended = data["recommended"] as List<Recipe>;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ExploreSearchBar(),

                const SizedBox(height: 10),
                const SectionTitle(title: "🥗 Categories"),
                const CategoryList(),

                const SizedBox(height: 10),
                if (recommended.isNotEmpty) ...[
                  const SectionTitle(title: "✨ For You"),
                  TrendingRecipesList(recipes: recommended),
                ],

                const SizedBox(height: 10),
                const SectionTitle(title: "🔥 Trending"),
                TrendingRecipesList(recipes: trending),

                const SizedBox(height: 10),
                if (bookmarks.isNotEmpty) ...[
                  const SectionTitle(title: "❤️ Based on Bookmarks"),
                  TrendingRecipesList(recipes: bookmarks),
                ] else ...[
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      "Add bookmarks to get recommendations",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ],

                const SizedBox(height: 10),
                const SectionTitle(title: "🥗 Healthy"),
                TrendingRecipesList(recipes: healthy),

                const SizedBox(height: 10),
                const SectionTitle(title: "⚡ Quick Meals"),
                TrendingRecipesList(recipes: quick),

                const SizedBox(height: 20),
              ],
            ),
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