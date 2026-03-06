import 'recipe.dart';

class ScheduledRecipe {
  final String id;
  final Recipe recipe;
  final DateTime date;
  int quantity; 

  ScheduledRecipe({
    required this.id,
    required this.recipe,
    required this.date,
    this.quantity = 1,
  });
}
