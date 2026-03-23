import '../repository/recipe_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/recipe_api_service.dart';
final recipeApiServiceProvider = Provider((ref) {
  return RecipeApiService();
});
final recipeRepositoryProvider = Provider((ref) {
  final api = ref.read(recipeApiServiceProvider);

  return RecipeRepository(api);
});
//ref.read(recipesProvider.notifier).search(value)