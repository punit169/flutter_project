import 'dart:convert';
import 'package:http/http.dart' as http;
import 'recipe.dart';

class SpoonacularService {

  final String apiKey = "de126a93d5154180befda9883551b56c";

  Future<List<Recipe>> fetchRecipes({int offset = 0, String query = ""}) async {

    final url = Uri.parse(
        "https://api.spoonacular.com/recipes/complexSearch?apiKey=$apiKey&number=20&offset=$offset&query=$query");

    final response = await http.get(url);

    final data = jsonDecode(response.body);

    return (data['results'] as List).map((r) {

      return Recipe(
        id: r['id'],
        title: r['title'],
        image: r['image'],
        ingredients: [],
        instructions: [],
      );

    }).toList();
  }
}