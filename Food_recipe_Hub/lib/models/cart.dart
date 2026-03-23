import 'recipe.dart';
class CartItem {
  final String name;
  final String amount;
  final String unit;
  final String recipeName;
  DateTime? scheduledTime;
  bool isChecked;

  CartItem({
    required this.name,
    required this.amount,
    required this.unit,
    required this.recipeName,
    this.scheduledTime,
    this.isChecked = false,
  });
}
class MealPlan {
  final String name;
  final String amount;
  final String unit;
  final String recipeName;
  final List<Ingredient> ingredient;
  DateTime? scheduledTime;
  bool isChecked;
  final int servings;

  MealPlan({
    required this.name,
    required this.amount,
    required this.unit,
    required this.recipeName,
    this.scheduledTime,
    required this.ingredient,
    this.isChecked = false,
    required this.servings,
  });
}