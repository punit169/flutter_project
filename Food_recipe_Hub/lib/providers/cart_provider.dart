import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
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
  void addMultipleItems(List<CartItem> items) {
    state = [...state, ...items];
  }
  List<CartItem> get mergedItems {
    final Map<String, CartItem> merged = {};

    for (var item in state) {
      final key = "${item.name}_${item.unit}".toLowerCase();

      if (merged.containsKey(key)) {
        final existing = merged[key]!;

        merged[key] = CartItem(
          name: existing.name,
          amount: existing.amount + item.amount,
          unit: existing.unit,
          recipeName: existing.recipeName,
        );
      } else {
        merged[key] = item;
      }
    }

    return merged.values.toList();
  }
}