import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/recipe.dart';
import '../services/Api_service.dart';

final recipesProvider =
StateNotifierProvider<RecipesNotifier, List<Recipe>>((ref) {
  return RecipesNotifier();
});

class RecipesNotifier extends StateNotifier<List<Recipe>> {
  RecipesNotifier() : super([]) {
    loadRecipes();
  }

  final ApiService _service = ApiService();

  int _offset = 0;
  String _query = '';
  bool _isLoading = false;

  Future<void> loadRecipes({String query = ''}) async {
    if (_isLoading) return;

    _isLoading = true;

    try {
      if (query != _query) {
        _offset = 0;
        state = [];
        _query = query;
      }

      final newRecipes =
      await _service.fetchRecipes(query: _query, offset: _offset);

      state = [...state, ...newRecipes];
      _offset += 20;
    } catch (e) {
      print("Error loading recipes: $e");
    }

    _isLoading = false;
  }

  Future<void> loadMore() async {
    await loadRecipes(query: _query);
  }

  Future<void> search(String query) async {
    _offset = 0;
    state = [];
    _query = query;

    await loadRecipes(query: query);
  }
}