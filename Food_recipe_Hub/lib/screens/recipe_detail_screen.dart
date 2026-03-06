import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/spoonacular_service.dart';
import '../models/recipe.dart';
import '../providers/cart_provider.dart';
import '../providers/meal_plan_provider.dart';

class RecipeDetailScreen extends ConsumerStatefulWidget {
  final Recipe recipe;

  const RecipeDetailScreen({super.key, required this.recipe});



  @override
  ConsumerState<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends ConsumerState<RecipeDetailScreen> {

  late Future<Recipe> recipeFuture;

  @override
  void initState() {
    super.initState();

    recipeFuture =
        SpoonacularService().fetchRecipeDetails(widget.recipe.id);
  }
  Future<void> scheduleMeal(
      BuildContext context,
      WidgetRef ref,
      Recipe recipe,
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
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Meal Scheduled")),
    );
  }
  @override
  Widget build(BuildContext context) {
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
              ElevatedButton.icon(
                icon: const Icon(Icons.schedule),
                label: const Text("Schedule Meal"),
                onPressed: () {
                  scheduleMeal(context, ref, recipe);
                },
              )
            ],
          );
        },
      ),
    );
  }
}