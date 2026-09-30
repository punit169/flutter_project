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

  /// Returns instructions with raw HTML tags stripped for clean display.
  String get cleanInstructions {
    if (instructions.trim().isEmpty) {
      return "No instructions available.";
    }
    final normalized = instructions
        .replaceAll('<li>', '\n• ')
        .replaceAll('<LI>', '\n• ')
        .replaceAll('</li>', '\n')
        .replaceAll('</LI>', '\n')
        .replaceAll('</p>', '\n\n')
        .replaceAll('</P>', '\n\n')
        .replaceAll('<br>', '\n')
        .replaceAll('<br/>', '\n')
        .replaceAll('<br />', '\n');

    final buffer = StringBuffer();
    bool inTag = false;
    for (int i = 0; i < normalized.length; i++) {
      final ch = normalized[i];
      if (ch == '<') {
        inTag = true;
      } else if (ch == '>') {
        inTag = false;
      } else if (!inTag) {
        buffer.write(ch);
      }
    }

    final result = buffer.toString().trim();
    return result.isEmpty ? "No instructions available." : result;
  }

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