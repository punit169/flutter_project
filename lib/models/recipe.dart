class Recipe {
  final int id;
  final String title;
  final String image;
  final List<Ingredient> ingredients;
  final String instructions;

  Recipe({
    required this.id,
    required this.title,
    required this.image,
    required this.ingredients,
    required this.instructions,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    List<Ingredient> ingredientsList = [];

    if (json["extendedIngredients"] != null) {
      ingredientsList = (json["extendedIngredients"] as List)
          .map((ing) => Ingredient(
        name: ing["name"] ?? "",
        amount: (ing["amount"] as num?)?.toDouble() ?? 0,
        unit: ing["unit"] ?? "",
      ))
          .toList();
    }

    return Recipe(
      id: json["id"],
      title: json["title"] ?? "",
      image: json["image"] ?? "",
      ingredients: ingredientsList,
      instructions: json["instructions"] ?? "No instructions available",
    );
  }
}
class Ingredient {
  final String name;
  final double amount;
  final String unit;

  Ingredient({
    required this.name,
    required this.amount,
    required this.unit,
  });
}