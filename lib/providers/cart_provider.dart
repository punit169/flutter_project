import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cart.dart';

final cartProvider =
StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void addIngredient(CartItem item) {
    final existingIndex =
    state.indexWhere((element) => element.name == item.name);

    if (existingIndex >= 0) {
      final existing = state[existingIndex];

      final updated = CartItem(
        name: existing.name,
        amount: existing.amount + item.amount,
        unit: existing.unit,
        recipeName: existing.recipeName,
      );

      final newState = [...state];
      newState[existingIndex] = updated;

      state = newState;
    } else {
      state = [...state, item];
    }
  }
  void toggleChecked(int index) {
    final item = state[index];

    item.isChecked = !item.isChecked;

    state = [...state];
  }
  void removeItem(int index) {
    state = [...state]..removeAt(index);
  }
  void clearCart() {
    state = [];
  }
}