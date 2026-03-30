// class _RecipesScreenState extends ConsumerState<RecipesScreen> {
//   final List<Recipe> _recipes = [];
//   int offset = 0;
//   bool loading = false;
//
//   @override
//   void initState() {
//     super.initState();
//     loadRecipes();
//   }
//
//   Future<void> loadRecipes() async {
//     if (loading) return;
//
//     loading = true;
//
//     final newRecipes =
//     await SpoonacularService().fetchRecipes(offset: offset);
//
//     setState(() {
//       offset += 20;
//       _recipes.addAll(newRecipes);
//     });
//
//     loading = false;
//   }

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

  // const RecipesScreen({super.key, this.initialQuery});
  @override
  ConsumerState<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends ConsumerState<RecipesScreen> {

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  List<int> likedIds = [];

  @override
  void initState() {
    super.initState();


    if (widget.initialQuery != null) {
      Future.microtask(() {
        ref.read(recipesProvider.notifier)
            .search(widget.initialQuery!);
      });
    }

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        ref.read(recipesProvider.notifier).loadMore();
      }
    });
  }


  @override
  Widget build(BuildContext context) {

    final recipes = ref.watch(recipesProvider);
    final favorites = ref.watch(favoritesProvider);
    final likedIds = ref.watch(likeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Recipes"),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark,color: Colors.blueAccent,),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const FavoritesListScreen(),
                ),
              );
            },
          )
        ],
      ),

      body: Column(
        children: [

          // SEARCH BAR
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

          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: recipes.length,
              itemBuilder: (context, index) {

                final Recipe recipe = recipes[index];
                final isFav =
                favorites.contains(recipe.id.toString());
                bool isLiked = likedIds.contains(recipe.id);

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
                    children:[
                      IconButton(
                        icon: Icon(
                          isFav
                              ? Icons.bookmark
                              : Icons.bookmark_border,
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
                        builder: (_) =>
                            RecipeDetailScreen(recipe: recipe),
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