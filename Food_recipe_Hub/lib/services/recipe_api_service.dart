import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import '../models/recipe.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class RecipeApiService {

  String get apiKey => dotenv.env['API_KEY_TWO'] ?? '';
  String get baseUrl => dotenv.env['BASE_URL'] ?? '';

  Future<Recipe> getRecipeDetail(int id) async {
    if (apiKey.isEmpty) {
      throw Exception("API Key missing in .env");
    }
    final url = Uri.parse(
      "$baseUrl/recipes/$id/information?apiKey=$apiKey",
    );

    final response = await http.get(url);
    if (response.statusCode != 200) {
      throw Exception("API failed: ${response.statusCode}");
    }
    final data = jsonDecode(response.body);

    return Recipe.fromJson(data);
  }

  Future<List<int>> getTrendingRecipeIds() async {
    final snapshot = await FirebaseFirestore.instance
        .collection("likes")
        .orderBy("count", descending: true)
        .limit(10)
        .get();

    return snapshot.docs
        .map((doc) => int.parse(doc.id))
        .toList();
  }

  Future<List<Recipe>> getHealthyRecipes() async {
    if (apiKey.isEmpty) {
      throw Exception("API Key missing in .env");
    }
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
      "$baseUrl/recipes/complexSearch?query=${Uri.encodeComponent(query)}&number=10&apiKey=$apiKey",
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final List results = data["results"]?? [];

      return results.map((e) => Recipe.fromJson(e)).toList();
    } else {
      throw Exception("Failed to search recipes");
    }

  }
  Future<List<Recipe>> getRecommendedRecipes(String query) async {
    final url = Uri.parse(
      "$baseUrl/recipes/complexSearch?query=${Uri.encodeComponent(query)}&number=10&apiKey=$apiKey",
    );

    final res = await http.get(url);
    final data = jsonDecode(res.body);

    return (data["results"] as List)
        .map((e) => Recipe.fromJson(e))
        .toList();
  }
}