import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/recipe.dart';
import '../services/Api_service.dart';

// ─────────────────────────────────────────────────────────────
// WHY we need a state object instead of just List<Recipe>:
//
// Before: state = List<Recipe>
// The UI had no way to know if more data was being loaded.
// _isLoading was a private variable inside the notifier —
// completely invisible to the UI.
//
// After: state = RecipeState (recipes + isLoading)
// Now the UI can watch isLoading and show/hide a spinner.
// This is the correct pattern when your UI needs to react
// to multiple pieces of related state together.
//
// Interview concept: This is basically a mini version of
// the BLoC pattern — state is a single immutable object,
// and the notifier emits new state objects on every change.
// ─────────────────────────────────────────────────────────────

// State object that holds both the recipe list AND loading status
class RecipeState {
  final List<Recipe> recipes;
  final bool isLoading;

  const RecipeState({
    required this.recipes,
    required this.isLoading,
  });

  // copyWith lets us update one field without touching the other
  // e.g. state.copyWith(isLoading: true) keeps recipes intact
  RecipeState copyWith({
    List<Recipe>? recipes,
    bool? isLoading,
  }) {
    return RecipeState(
      recipes: recipes ?? this.recipes,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

final recipesProvider =
StateNotifierProvider<RecipesNotifier, RecipeState>((ref) {
  return RecipesNotifier();
});

class RecipesNotifier extends StateNotifier<RecipeState> {
  RecipesNotifier() : super(const RecipeState(recipes: [], isLoading: false)) {
    loadRecipes();
  }

  final ApiService _service = ApiService();

  int _offset = 0;
  String _query = '';

  Future<void> loadRecipes({String query = ''}) async {
    // Guard: don't fire if already loading
    // This prevents duplicate API calls when scroll listener
    // fires multiple times while user stays near the bottom
    if (state.isLoading) return;

    // ✅ FIX: set isLoading: true so UI can show spinner
    state = state.copyWith(isLoading: true);

    try {
      if (query != _query) {
        _offset = 0;
        _query = query;
        // Clear recipes when query changes, keep isLoading: true
        state = state.copyWith(recipes: []);
      }

      final newRecipes = await _service.fetchRecipes(
        query: _query,
        offset: _offset,
      );

      state = state.copyWith(
        recipes: [...state.recipes, ...newRecipes],
        isLoading: false, // ✅ hide spinner when done
      );

      _offset += 20;
    } catch (e) {
      debugPrint("Error loading recipes: $e"); // use debugPrint not print
      state = state.copyWith(isLoading: false); // ✅ always hide spinner on error too
    }
  }

  Future<void> loadMore() async {
    await loadRecipes(query: _query);
  }

  Future<void> search(String query) async {
    _offset = 0;
    _query = query;
    state = const RecipeState(recipes: [], isLoading: false);
    await loadRecipes(query: query);
  }
}