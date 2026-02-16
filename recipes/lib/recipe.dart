class Ingredient {
  final double quantity;
  final String measure;
  final String name;

  const Ingredient(
      this.quantity,
      this.measure,
      this.name,
      );
}

class Recipe {
  final String label;
  final String imageUrl;
  final int servings;
  final List<Ingredient> ingredients;

  const Recipe(
      this.label,
      this.imageUrl,
      this.servings,
      this.ingredients,
      );

  static const List<Recipe> samples = [

    // Manchurian
    Recipe(
      'Manchurian',
      'assets/manchurian.jpeg',
      3,
      [
        Ingredient(1, 'cup', 'Cabbage'),
        Ingredient(0.5, 'cup', 'Carrot'),
        Ingredient(0.25, 'cup', 'Capsicum'),
        Ingredient(2, 'tbsp', 'Flour'),
        Ingredient(2, 'tbsp', 'Cornflour'),
        Ingredient(1, 'tbsp', 'Soy Sauce'),
        Ingredient(1, 'tbsp', 'Chilli Sauce'),
        Ingredient(1, 'tsp', 'Garlic'),
        Ingredient(1, 'tsp', 'Ginger'),
      ],
    ),

    // Tomato Soup
    Recipe(
      'Tomato Soup',
      'assets/Tomato Soup.jpeg',
      2,
      [
        Ingredient(4, 'pieces', 'Tomatoes'),
        Ingredient(1, 'tbsp', 'Butter'),
        Ingredient(2, 'cups', 'Water'),
        Ingredient(1, 'tsp', 'Salt'),
        Ingredient(0.5, 'tsp', 'Black Pepper'),
        Ingredient(1, 'tsp', 'Sugar'),
        Ingredient(2, 'tbsp', 'Cream'),
      ],
    ),

    // Sandwitch
    Recipe(
      'Grilled Cheese Sandwich',
      'assets/grilled_cheese_sandwitch.jpeg',
      1,
      [
        Ingredient(2, 'slices', 'Bread'),
        Ingredient(2, 'slices', 'Cheese'),
        Ingredient(1, 'tbsp', 'Butter'),
      ],
    ),

    // Cookies
    Recipe(
      'Chocolate Chip Cookies',
      'assets/Chocolate_Chip_Cookies.jpeg',
      12,
      [
        Ingredient(2, 'cups', 'Flour'),
        Ingredient(1, 'cup', 'Sugar'),
        Ingredient(0.5, 'cup', 'Butter'),
        Ingredient(0.5, 'cup', 'Chocolate Chips'),
        Ingredient(1, 'tsp', 'Vanilla Essence'),
      ],
    ),

    // Taco Salad
    Recipe(
      'Taco Salad',
      'assets/Taco Salad.jpeg',
      1,
      [
        Ingredient(4, 'oz', 'Nachos'),
        Ingredient(3, 'oz', 'Taco Meat'),
        Ingredient(0.5, 'cup', 'Cheese'),
        Ingredient(0.25, 'cup', 'Tomatoes'),
        Ingredient(0.25, 'cup', 'Lettuce'),
      ],
    ),

    // Pizza
    Recipe(
      'Pizza',
      'assets/pizza.jpeg',
      4,
      [
        Ingredient(1, 'piece', 'Pizza Base'),
        Ingredient(0.5, 'cup', 'Pizza Sauce'),
        Ingredient(1, 'cup', 'Mozzarella Cheese'),
        Ingredient(0.25, 'cup', 'Capsicum'),
        Ingredient(0.25, 'cup', 'Onion'),
        Ingredient(0.25, 'cup', 'Corn'),
        Ingredient(1, 'tsp', 'Oregano'),
        Ingredient(1, 'tsp', 'Chilli Flakes'),
      ],
    ),
  ];
}
