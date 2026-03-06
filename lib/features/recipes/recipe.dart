class Recipe {
  final int id;
  final String title;
  final String image;
  final List ingredients;
  final List instructions;

  Recipe({
    required this.id,
    required this.title,
    required this.image,
    required this.ingredients,
    required this.instructions,
  });
}