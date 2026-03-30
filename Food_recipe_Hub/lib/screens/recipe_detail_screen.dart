import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/Api_service.dart';
import '../models/recipe.dart';
import '../providers/cart_provider.dart';
import '../providers/meal_plan_provider.dart';
import '../models/cart.dart';
import '../providers/comment_provider.dart';
import '../providers/comment_action_provider.dart';
import '../providers/user_provider.dart';
import '../utils/time_utils.dart';

class RecipeDetailScreen extends ConsumerStatefulWidget {
  final Recipe recipe;

  const RecipeDetailScreen({super.key, required this.recipe});



  @override
  ConsumerState<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends ConsumerState<RecipeDetailScreen> {

  late Future<Recipe> recipeFuture;
  int servings = 1;
  @override
  void initState() {
    super.initState();

    recipeFuture =
        ApiService().fetchRecipeDetails(widget.recipe.id);
  }

  Future<void> scheduleMeal(
      BuildContext context,
      WidgetRef ref,
      Recipe recipe, int servings,
      ) async {

    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time == null) return;

    final scheduledDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    ref.read(mealPlanProvider.notifier).scheduleMeal(
      recipe,
      scheduledDateTime,
      servings
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Meal Scheduled")),
    );
  }

  @override
  Widget build(BuildContext context) {
    // final comments = ref.watch(commentsProvider(widget.recipe.id));
    final commentController = TextEditingController();
    final commentsAsync = ref.watch(commentsProvider(widget.recipe.id));



    return Scaffold(
      appBar: AppBar(title: Text(widget.recipe.title)),

      body: FutureBuilder<Recipe>(
        future: recipeFuture,
        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final recipe = snapshot.data!;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [

              Image.network(recipe.image),

              const SizedBox(height: 20),

              const Text(
                "Ingredients",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              ...recipe.ingredients.map(
                    (i) => ListTile(
                  leading: const Icon(Icons.check),
                  title: Text(
                      "${i.name}  ${i.amount} ${i.unit}"),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () {
                      if (servings > 1) {
                        setState(() {
                          servings--;
                        });
                      }
                    },
                  ),

                  Text(
                    "$servings servings",
                    style: const TextStyle(fontSize: 18),
                  ),

                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      setState(() {
                        servings++;
                      });
                    },
                  ),
                ],
              ),

              ElevatedButton.icon(
                icon: const Icon(Icons.shopping_cart),
                label: const Text("Add to Cart"),
                onPressed: () {

                  final scaledIngredients = recipe.ingredients.map((i) {

                    final double newAmount = i.amount * servings;

                    return CartItem(
                      name: i.name,
                      amount: newAmount,
                      unit: i.unit,
                      recipeName: recipe.title,
                    );

                  }).toList();

                  ref.read(cartProvider.notifier)
                      .addMultipleItems(scaledIngredients);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Added to Cart")),
                  );

                },
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.schedule),
                label: const Text("Schedule Meal"),
                onPressed: () {
                  scheduleMeal(context, ref, recipe , servings);
                },
              ),
              const SizedBox(height: 20),

              const Text(
                "💬 Comments",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: commentController,
                      decoration: const InputDecoration(
                        hintText: "Add a comment...",
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () {
                      ref.read(commentActionsProvider)
                          .addComment(recipe.id, commentController.text, ref);

                      commentController.clear();
                    },
                  ),
                ],
              ),
              commentsAsync.when(
                loading: () => const CircularProgressIndicator(),
                error: (e, _) => const Text("Error loading comments"),
                data: (comments) {
                  if (comments.isEmpty) {
                    return const Text("No comments yet");
                  }

                  return Column(
                    children: comments.map((c) {
                      final user = ref.watch(userProvider).value;
                      final isLiked = c.likedBy.contains(user?.uid);

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          leading: StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection("users")
                                .doc(c.userId)
                                .snapshots(),
                            builder: (context, snapshot) {
                              final data = snapshot.data?.data();
                              final username = data?["username"] ?? "User";
                              final photoPath = data?["photoPath"];

                              ImageProvider imageProvider;

                              if (photoPath != null &&
                                  File(photoPath).existsSync()) {
                                imageProvider = FileImage(File(photoPath));
                              } else {
                                imageProvider = NetworkImage(
                                  "https://ui-avatars.com/api/?name=$username",
                                );
                              }

                              return CircleAvatar(
                                radius: 18,
                                backgroundImage: imageProvider,
                              );
                            },
                          ),
                          title:  Text(c.username),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(c.text),

                              const SizedBox(height: 4),

                              Text(
                                timeAgo(c.createdAt),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),

                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // LIKE COMMENT
                              IconButton(
                                icon: Icon(
                                  isLiked
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  ref
                                      .read(commentActionsProvider)
                                      .toggleLikeComment(
                                        recipe.id,
                                        c.id,
                                        user!.uid,
                                      );
                                },
                              ),
                              Text("${c.likes}"),

                              // 🗑 DELETE
                              if (user?.uid == c.userId)
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    ref
                                        .read(commentActionsProvider)
                                        .deleteComment(
                                          recipe.id,
                                          c.id,
                                        );
                                  },
                                ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),

            ],
          );
        },
      ),
    );
  }
}