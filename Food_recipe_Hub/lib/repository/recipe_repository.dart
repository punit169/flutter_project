import '../models/recipe.dart';
import '../services/recipe_api_service.dart';

class RecipeRepository {
  final RecipeApiService api;

  RecipeRepository(this.api);

  //  Trending
  Future<List<Recipe>> getTrending() async {
    return await api.getTrendingRecipes();
  }

  //  Healthy
  Future<List<Recipe>> getHealthy() async {
    return await api.getHealthyRecipes();
  }

  // Quick meals
  Future<List<Recipe>> getQuick() async {
    return await api.getQuickRecipes();
  }

  //  Search (reusing existing logic)
  Future<List<Recipe>> searchRecipes(String query) async {
    return await api.searchRecipes(query);
  }

  //  Recipe detail
  Future<Recipe> getRecipeDetail(int id) async {
    return await api.getRecipeDetail(id);
  }
}

