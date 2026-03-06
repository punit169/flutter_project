import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/recipe.dart';
class SpoonacularService {
  static const apiKey = "91864d74823f435ba78e81536d8276d2";

  Future<List<Recipe>> fetchRecipes({
    int offset = 0,
    String query = '',
  }) async {
    final url = Uri.parse(
        "https://api.spoonacular.com/recipes/complexSearch"
            "?apiKey=$apiKey"
            "&number=20"
            "&offset=$offset"
            "&query=$query"
            "&addRecipeInformation=true"
    );

    final res = await http.get(url);
    final data = jsonDecode(res.body);


    final List results = data["results"];
    return results.map((json) => Recipe.fromJson(json)).toList();
  }

  Future<Recipe> fetchRecipeDetails(int id) async {
    final url = Uri.parse(
        "https://api.spoonacular.com/recipes/$id/information?apiKey=$apiKey"
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception("Failed to load recipe details");
    }

    final data = jsonDecode(response.body);

    List<Ingredient> ingredients = [];

    if (data["extendedIngredients"] != null) {
      ingredients = (data["extendedIngredients"] as List)
          .map((i) => Ingredient(
        name: i["name"] ?? "",
        amount: (i["amount"] ?? 0).toDouble(),
        unit: i["unit"] ?? "",
      ))
          .toList();
    }

    return Recipe(
      id: data["id"],
      title: data["title"] ?? "",
      image: data["image"] ?? "",
      ingredients: ingredients,
      instructions: "",
    );
  }
}