import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/recipe.dart';
import '../models/cart.dart';

class MealPlanNotifier extends StateNotifier<List<MealPlan>> {
  MealPlanNotifier() : super([]);

  void scheduleMeal(Recipe recipe, DateTime time , int servings) {
    state = [
      ...state,
      MealPlan(
          name: recipe.id.toString(),
          scheduledTime: time,
          amount: recipe.ingredients.map((i) => i.amount).toString(),
          unit: recipe.ingredients.map((i) => i.unit).toString(),
          recipeName: recipe.title,
          ingredient: recipe.ingredients,
          servings: servings,
      ),

    ];
  }
  void toggleChecked(int index) {
    final item = state[index];
    item.isChecked = !item.isChecked;
    state = [...state];
  }
  void removeMeal(MealPlan plan) {
    state = state.where((p) => p != plan).toList();
  }
  void clearMeals() {
    state = [];
  }
}


final mealPlanProvider =
StateNotifierProvider<MealPlanNotifier, List<MealPlan>>(
      (ref) => MealPlanNotifier(),
);