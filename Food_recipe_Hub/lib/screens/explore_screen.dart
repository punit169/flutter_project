import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_recipe_hub/models/recipe.dart';
import '../providers/like_provider.dart';
import '../widgets/explore_widgets.dart';
import '../widgets/list_widgets.dart';
import '../providers/bookmark_provider.dart';
import '../screens/profile_screen.dart';
import '../providers/user_provider.dart';
import '../providers/explore_provider.dart';
import '../utils/image_utils.dart';
// recipe_repository_provider import removed — was never used in this screen

class ExploreScreen extends ConsumerWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exploreAsync = ref.watch(exploreDataProvider);
    final bookmarkIds = ref.watch(favoritesProvider);
    final userAsync = ref.watch(userProvider);

    ImageProvider getProfileImage(dynamic user) =>
        getProfileImageProvider(user?.photoPath, user?.username ?? "User");

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
                      MaterialPageRoute(builder: (_) => const ProfileScreen()),
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
        // Initial load — full screen spinner
        loading: () => const Center(child: CircularProgressIndicator()),

        // Error state — show message + allow pull to retry
        // ─────────────────────────────────────────────────
        // WHY RefreshIndicator on error too?
        // If the first load fails (no internet, API limit),
        // the user is stuck on an error screen with no way
        // out except restarting the app. Wrapping with
        // RefreshIndicator lets them pull down to retry.
        // ─────────────────────────────────────────────────
        error: (e, _) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(exploreDataProvider);
          },
          child: ListView(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.7,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.wifi_off, size: 60, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        "Something went wrong",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Pull down to retry",
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        data: (data) {
          final trending = data["trending"] as List<Recipe>;
          final healthy = data["healthy"] as List<Recipe>;
          final quick = data["quick"] as List<Recipe>;
          final recommended =
              (data["recommended"] as List<Recipe>?) ?? <Recipe>[];
          final bookmarks =
              (data["bookmarks"] as List<Recipe>?) ??
              trending.where((r) => bookmarkIds.contains(r.id)).toList();
          final forYouList =
              recommended.isNotEmpty ? recommended : bookmarks;

          // ─────────────────────────────────────────────────
          // FIX: Wrap SingleChildScrollView with RefreshIndicator
          //
          // HOW RefreshIndicator works:
          // 1. User pulls down past a threshold
          // 2. Flutter shows the circular refresh animation
          // 3. onRefresh() callback is called — must return Future
          // 4. When the Future completes, animation stops
          //
          // ref.invalidate(exploreDataProvider) tells Riverpod:
          // "throw away the cached data and re-run the provider"
          // Since keepAlive() is set, this is the ONLY way to
          // force a refresh — invalidate overrides keepAlive.
          //
          // WHY not ref.refresh()? Both work, but invalidate()
          // is preferred because it schedules the refresh
          // asynchronously — safer with keepAlive providers.
          // ─────────────────────────────────────────────────
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(exploreDataProvider);

              // Wait for the new data to load before hiding
              // the refresh indicator animation
              await ref.read(exploreDataProvider.future);
            },
            child: SingleChildScrollView(

              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ExploreSearchBar(),

                  const SizedBox(height: 10),
                  const SectionTitle(title: "🥗 Categories"),
                  const CategoryList(),

                  const SizedBox(height: 10),
                  const SectionTitle(title: "🔥 Trending"),
                  TrendingRecipesList(recipes: trending),

                  const SizedBox(height: 10),
                  if (forYouList.isNotEmpty) ...[
                    const SectionTitle(title: "✨ For You"),
                    TrendingRecipesList(recipes: forYouList),
                  ] else ...[
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        "Like or bookmark recipes to get recommendations",
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
          Container(height: 120, color: Colors.grey[300]),
          const SizedBox(height: 8),
          Container(height: 10, color: Colors.grey[300]),
        ],
      ),
    );
  }
}