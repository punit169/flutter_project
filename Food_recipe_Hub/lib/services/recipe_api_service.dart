import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import '../models/recipe.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class RecipeApiService {

  String get apiKey => dotenv.env['API_KEY_TWO'] ?? '';
  String get baseUrl => dotenv.env['BASE_URL'] ?? '';

  // Helper — throws a clean exception for any non-200 response
  // including 402 (quota exceeded) so the error message is clear
  void _checkStatus(http.Response response, String context) {
    if (response.statusCode == 402) {
      throw Exception('API quota exceeded. Try again tomorrow or switch API key.');
    }
    if (response.statusCode != 200) {
      throw Exception('$context failed: ${response.statusCode}');
    }
  }

  Future<Recipe> getRecipeDetail(int id) async {
    if (apiKey.isEmpty) throw Exception('API Key missing in .env');

    final url = Uri.parse('$baseUrl/recipes/$id/information?apiKey=$apiKey');
    final response = await http.get(url);
    _checkStatus(response, 'Recipe detail');

    return Recipe.fromJson(jsonDecode(response.body));
  }

  Future<List<Recipe>> getRecipesByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    if (apiKey.isEmpty) throw Exception('API Key missing in .env');

    final joinedIds = ids.join(',');
    final url = Uri.parse(
      '$baseUrl/recipes/informationBulk?ids=$joinedIds&apiKey=$apiKey',
    );

    final response = await http.get(url);
    _checkStatus(response, 'Bulk fetch');

    final List data = jsonDecode(response.body);
    return data.map((json) => Recipe.fromJson(json)).toList();
  }

  Future<List<int>> getTrendingRecipeIds() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('likes')
        .orderBy('count', descending: true)
        .limit(10)
        .get();

    return snapshot.docs.map((doc) => int.parse(doc.id)).toList();
  }

  Future<List<Recipe>> getHealthyRecipes() async {
    if (apiKey.isEmpty) throw Exception('API Key missing in .env');

    final url = Uri.parse(
      '$baseUrl/recipes/complexSearch?diet=vegetarian&number=10&apiKey=$apiKey',
    );

    final response = await http.get(url);
    _checkStatus(response, 'Healthy recipes');

    final data = jsonDecode(response.body);
    // FIX: was `data["results"] as List` — crashes when quota hit returns no "results" key
    final List results = data['results'] ?? [];
    return results.map((e) => Recipe.fromJson(e)).toList();
  }

  Future<List<Recipe>> getQuickRecipes() async {
    if (apiKey.isEmpty) throw Exception('API Key missing in .env');

    final url = Uri.parse(
      '$baseUrl/recipes/complexSearch?maxReadyTime=20&number=10&apiKey=$apiKey',
    );

    final response = await http.get(url);
    _checkStatus(response, 'Quick recipes');

    final data = jsonDecode(response.body);
    // FIX: same null cast issue as getHealthyRecipes
    final List results = data['results'] ?? [];
    return results.map((e) => Recipe.fromJson(e)).toList();
  }

  Future<List<Recipe>> searchRecipes(String query) async {
    final url = Uri.parse(
      '$baseUrl/recipes/complexSearch?query=${Uri.encodeComponent(query)}&number=10&apiKey=$apiKey',
    );

    final response = await http.get(url);
    _checkStatus(response, 'Search');

    final data = jsonDecode(response.body);
    final List results = data['results'] ?? [];
    return results.map((e) => Recipe.fromJson(e)).toList();
  }

  Future<List<Recipe>> getRecommendedRecipes(String query) async {
    final url = Uri.parse(
      '$baseUrl/recipes/complexSearch?query=${Uri.encodeComponent(query)}&number=10&apiKey=$apiKey',
    );

    final res = await http.get(url);
    _checkStatus(res, 'Recommended recipes');

    final data = jsonDecode(res.body);
    final List results = data['results'] ?? [];
    return results.map((e) => Recipe.fromJson(e)).toList();
  }
}