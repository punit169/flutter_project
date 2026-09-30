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
import '../utils/image_utils.dart';
// dart:io removed — no longer needed since we use image_utils for all photo display

class RecipeDetailScreen extends ConsumerStatefulWidget {
  final Recipe recipe;
  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  ConsumerState<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends ConsumerState<RecipeDetailScreen> {
  late Future<Recipe> recipeFuture;
  int servings = 1;

  // FIX: commentController moved here from build()
  // Same bug as ProfileScreen — creating a controller inside build()
  // means a new controller is created on every rebuild → memory leak
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    recipeFuture = ApiService().fetchRecipeDetails(widget.recipe.id);
  }

  @override
  void dispose() {
    // Always dispose controllers to free memory
    _commentController.dispose();
    super.dispose();
  }

  Future<void> scheduleMeal(
      BuildContext context,
      WidgetRef ref,
      Recipe recipe,
      int servings,
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
      date.year, date.month, date.day,
      time.hour, time.minute,
    );

    await ref.read(mealPlanProvider.notifier).scheduleMeal(
      recipe,
      scheduledDateTime,
      servings,
      // If notification permission denied -> show helpful message
      // Meal is still saved — user just won't get a reminder
      onNotificationDenied: () {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Meal saved! Enable notifications in Settings to get reminders.",
              ),
              duration: Duration(seconds: 4),
            ),
          );
        }
      },
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Meal Scheduled ✅")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              ...recipe.ingredients.map(
                    (i) => ListTile(
                  leading: const Icon(Icons.check),
                  title: Text("${i.name}  ${i.amount} ${i.unit}"),
                ),
              ),

              // Servings scaler
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () {
                      if (servings > 1) setState(() => servings--);
                    },
                  ),
                  Text("$servings servings", style: const TextStyle(fontSize: 18)),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => setState(() => servings++),
                  ),
                ],
              ),

              ElevatedButton.icon(
                icon: const Icon(Icons.shopping_cart),
                label: const Text("Add to Cart"),
                onPressed: () {
                  final scaledIngredients = recipe.ingredients.map((i) {
                    return CartItem(
                      name: i.name,
                      amount: i.amount * servings,
                      unit: i.unit,
                      recipeName: recipe.title,
                    );
                  }).toList();

                  ref.read(cartProvider.notifier).addMultipleItems(scaledIngredients);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Added to Cart")),
                  );
                },
              ),

              ElevatedButton.icon(
                icon: const Icon(Icons.schedule),
                label: const Text("Schedule Meal"),
                onPressed: () => scheduleMeal(context, ref, recipe, servings),
              ),

              const SizedBox(height: 20),

              // ── Instructions Section ──────────────────────────
              const Text(
                "📖 Instructions",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                recipe.cleanInstructions,
                style: const TextStyle(fontSize: 15, height: 1.5),
              ),

              const SizedBox(height: 20),

              // ── Comments Section ──────────────────────────────
              const Text(
                "💬 Comments",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController, // ✅ using State-level controller
                      maxLength: 300, // medium priority fix — prevents huge comments
                      decoration: const InputDecoration(
                        hintText: "Add a comment...",
                        counterText: "", // hides the character counter UI
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () {
                      ref.read(commentActionsProvider).addComment(
                        recipe.id,
                        _commentController.text,
                        ref,
                      );
                      _commentController.clear();
                    },
                  ),
                ],
              ),

              commentsAsync.when(
                loading: () => const CircularProgressIndicator(),
                error: (e, _) => const Text("Error loading comments"),
                data: (comments) {
                  if (comments.isEmpty) return const Text("No comments yet");

                  return Column(
                    children: comments.map((c) {
                      final user = ref.watch(userProvider).value;
                      final isLiked = c.likedBy.contains(user?.uid);

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection("users")
                              .doc(c.userId)
                              .snapshots(),
                          builder: (context, snapshot) {
                            final data = snapshot.data?.data();
                            final username = data?["username"] ?? "User";
                            final photoPath = data?["photoPath"];

                            // ✅ getProfileImageProvider handles all 3 cases:
                            // null photoPath      → ui-avatars.com with username initial
                            // base64 string       → decoded MemoryImage
                            // http URL (legacy)   → NetworkImage
                            // decode failure      → fallback to ui-avatars.com
                            final imageProvider = getProfileImageProvider(
                              photoPath,
                              username,
                            );

                            return ListTile(
                              leading: CircleAvatar(
                                radius: 18,
                                backgroundImage: imageProvider,
                              ),
                              title: Text(
                                username,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(c.text),
                                  const SizedBox(height: 4),
                                  Text(
                                    timeAgo(c.createdAt),
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      isLiked ? Icons.favorite : Icons.favorite_border,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      ref.read(commentActionsProvider).toggleLikeComment(
                                        recipe.id, c.id, user!.uid,
                                      );
                                    },
                                  ),
                                  Text("${c.likes}"),
                                  if (user?.uid == c.userId)
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () {
                                        ref.read(commentActionsProvider).deleteComment(
                                          recipe.id, c.id,
                                        );
                                      },
                                    ),
                                ],
                              ),
                            );
                          },
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