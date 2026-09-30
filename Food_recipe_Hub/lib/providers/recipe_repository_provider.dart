import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/recipe_api_service.dart';

final recipeApiServiceProvider = Provider((ref) {
  return RecipeApiService();
});
