import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/cart.dart';

final cartProvider =
StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]) {
    loadCart(); // ✅ Load from Firestore on startup
  }

  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  // Helper — get current user's cart collection reference
  // WHY a getter: keeps code DRY — we reference this path
  // in every method so we define it once here
  CollectionReference get _cartRef => _db
      .collection("users")
      .doc(_auth.currentUser!.uid)
      .collection("cart");

  // ─────────────────────────────────────────────────────
  // LOAD — called on startup to restore cart from Firestore
  // ─────────────────────────────────────────────────────
  Future<void> loadCart() async {
    try {
      final snapshot = await _cartRef.get();
      final items = snapshot.docs
          .map((doc) => CartItem.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
      state = items;
    } catch (e) {
      debugPrint("LOAD CART ERROR: $e");
    }
  }

  // ─────────────────────────────────────────────────────
  // SAVE — overwrites entire cart in Firestore
  //
  // WHY overwrite instead of incremental updates?
  // Cart is small (rarely more than 20-30 items) and
  // operations like merging/removing items are complex
  // to track individually. Overwriting the whole cart
  // on every change is simpler and reliable.
  // For larger datasets, batch writes would be better.
  // ─────────────────────────────────────────────────────
  Future<void> _saveCart() async {
    try {
      // Step 1: Delete all existing cart docs
      final snapshot = await _cartRef.get();
      final batch = _db.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      // Step 2: Write current state as fresh docs
      for (var item in state) {
        batch.set(_cartRef.doc(), item.toMap());
      }

      // Batch commit — all deletes + writes happen atomically
      // WHY batch? Avoids partial saves if app closes mid-write
      await batch.commit();
    } catch (e) {
      debugPrint("SAVE CART ERROR: $e");
    }
  }

  // Add single ingredient — merges if same name exists
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
    _saveCart(); // sync to Firestore
  }

  // Toggle checked UI state — NOT saved to Firestore intentionally
  // (it's a temporary UI-only state, not worth persisting)
  void toggleChecked(int index) {
    final item = state[index];
    item.isChecked = !item.isChecked;
    state = [...state];
    // No _saveCart() here — isChecked is UI only
  }

  void removeItem(int index) {
    state = [...state]..removeAt(index);
    _saveCart();
  }

  Future<void> clearCart() async {
    state = [];
    await _saveCart();
  }

  void addMultipleItems(List<CartItem> items) {
    state = [...state, ...items];
    _saveCart();
  }

  // Merge items with same name+unit for display in CartScreen
  // This is a computed property — not stored, derived from state
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