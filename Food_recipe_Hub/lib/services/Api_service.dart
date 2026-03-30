import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/recipe.dart';

class ApiService {

  String get apiKey => dotenv.env['API_KEY'] ?? '';
  String get baseUrl => dotenv.env['BASE_URL'] ?? '';

  Future<List<Recipe>> fetchRecipes({
    int offset = 0,
    String query = '',
  }) async {
    if (apiKey.isEmpty) {
      throw Exception("API Key is missing. Check .env file");
    }

    final url = Uri.parse(
        "$baseUrl/recipes/complexSearch"
            "?apiKey=$apiKey"
            "&number=20"
            "&offset=$offset"
            "&query=${Uri.encodeComponent(query)}"
            "&addRecipeInformation=true"
    );

    final res = await http.get(url);

    if (res.statusCode != 200) {
      throw Exception("Failed to fetch recipes: ${res.statusCode}");
    }

    final data = jsonDecode(res.body);


    final List results = data["results"] ?? [];
    return results.map((json) => Recipe.fromJson(json)).toList();
  }

  Future<Recipe> fetchRecipeDetails(int id) async {
    final url = Uri.parse(
        "$baseUrl/recipes/$id/information?apiKey=$apiKey"
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