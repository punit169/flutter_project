import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recipe.dart';

class RecipeApiService {

  static const apiKey = "1842e5d5410d410e8280d45ff34ba512";
  static const baseUrl = "https://api.spoonacular.com";

  Future<Recipe> getRecipeDetail(int id) async {
    final url = Uri.parse(
      "$baseUrl/recipes/$id/information?apiKey=$apiKey",
    );

    final response = await http.get(url);
    final data = jsonDecode(response.body);

    return Recipe.fromJson(data);
  }

  Future<List<Recipe>> getTrendingRecipes() async {
    final url = Uri.parse(
      "$baseUrl/recipes/random?number=10&apiKey=$apiKey",
    );

    final response = await http.get(url);
    final data = jsonDecode(response.body);

    final List recipes = data["recipes"];

    return recipes.map((e) => Recipe.fromJson(e)).toList();
  }

  Future<List<Recipe>> getHealthyRecipes() async {
    final url = Uri.parse(
      "$baseUrl/recipes/complexSearch?diet=vegetarian&number=10&apiKey=$apiKey",
    );

    final response = await http.get(url);
    final data = jsonDecode(response.body);

    return (data["results"] as List)
        .map((e) => Recipe.fromJson(e))
        .toList();
  }

  Future<List<Recipe>> getQuickRecipes() async {
    final url = Uri.parse(
      "$baseUrl/recipes/complexSearch?maxReadyTime=20&number=10&apiKey=$apiKey",
    );

    final response = await http.get(url);
    final data = jsonDecode(response.body);

    return (data["results"] as List)
        .map((e) => Recipe.fromJson(e))
        .toList();
  }

  Future<List<Recipe>> getRecipesByIds(List<String> ids) async {
    List<Recipe> recipes = [];

    for (var id in ids) {
      final recipe = await getRecipeDetail(int.parse(id));
      recipes.add(recipe);
    }

    return recipes;
  }
  Future<List<Recipe>> searchRecipes(String query) async {
    final url = Uri.parse(
      "$baseUrl/recipes/complexSearch?query=$query&number=10&apiKey=$apiKey",
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final List results = data["results"];

      return results.map((e) => Recipe.fromJson(e)).toList();
    } else {
      throw Exception("Failed to search recipes");
    }

  }
  Future<List<Recipe>> getRecommendedRecipes(String query) async {
    final url = Uri.parse(
      "$baseUrl/recipes/complexSearch?query=$query&number=10&apiKey=$apiKey",
    );

    final res = await http.get(url);
    final data = jsonDecode(res.body);

    return (data["results"] as List)
        .map((e) => Recipe.fromJson(e))
        .toList();
  }
}