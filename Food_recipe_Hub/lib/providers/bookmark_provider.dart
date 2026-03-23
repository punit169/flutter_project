import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repository/favorites_repo.dart';

final favoritesRepositoryProvider =
Provider((ref) => FavoritesRepository());

final favoritesProvider =
StateNotifierProvider<FavoritesNotifier, Set<String>>((ref) {
  final repo = ref.read(favoritesRepositoryProvider);
  return FavoritesNotifier(repo);
});

class FavoritesNotifier extends StateNotifier<Set<String>> {
  final FavoritesRepository _repo;

  FavoritesNotifier(this._repo) : super({}) {
    _load();
  }

  Future<void> _load() async {
    state = await _repo.loadFavorites();
  }

  void toggle(String recipeId) {
    final newState = {...state};

    if (newState.contains(recipeId)) {
      newState.remove(recipeId);
    } else {
      newState.add(recipeId);
    }

    state = newState;
    _repo.saveFavorites(state);
  }

  bool isFavorite(String id) => state.contains(id);
}