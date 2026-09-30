import 'recipe.dart';

// ─────────────────────────────────────────────────────────────
// WHY toMap() and fromMap() are needed:
// Firestore stores data as Map<String, dynamic>.
// toMap()   → converts our Dart object INTO a map to SAVE to Firestore
// fromMap() → converts a Firestore map BACK into our Dart object to READ
//
// This is the standard serialization pattern for Firestore.
// Every model that needs to be saved to Firestore must have these.
// ─────────────────────────────────────────────────────────────

class CartItem {
  final String name;
  final double amount;
  final String unit;
  final String recipeName;
  DateTime? scheduledTime;
  bool isChecked;

  CartItem({
    required this.name,
    required this.amount,
    required this.unit,
    required this.recipeName,
    this.scheduledTime,
    this.isChecked = false,
  });

  // Convert CartItem → Map to save in Firestore
  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "amount": amount,
      "unit": unit,
      "recipeName": recipeName,
    };
    // isChecked intentionally NOT saved — it's a UI-only state
    // (checked/unchecked in shopping list). No need to persist it.
  }

  // Convert Firestore Map → CartItem
  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      name: map["name"] ?? "",
      amount: (map["amount"] as num?)?.toDouble() ?? 0,
      unit: map["unit"] ?? "",
      recipeName: map["recipeName"] ?? "",
    );
  }
}

class MealPlan {
  final String id;       // Firestore document ID — needed to delete specific plans
  final String name;     // recipeId as string
  final String amount;
  final String unit;
  final String recipeName;
  final List<Ingredient> ingredient;
  DateTime? scheduledTime;
  bool isChecked;
  final int servings;

  MealPlan({
    this.id = "",        // empty by default, set after Firestore save
    required this.name,
    required this.amount,
    required this.unit,
    required this.recipeName,
    this.scheduledTime,
    required this.ingredient,
    this.isChecked = false,
    required this.servings,
  });

  // Convert MealPlan → Map to save in Firestore
  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "recipeName": recipeName,
      "scheduledTime": scheduledTime?.toIso8601String(),
      "servings": servings,
      // Save ingredients as a list of maps
      // WHY: Firestore can't store Dart objects directly,
      // so we serialize each Ingredient into a simple map
      "ingredients": ingredient.map((i) => {
        "name": i.name,
        "amount": i.amount,
        "unit": i.unit,
      }).toList(),
    };
  }

  // Convert Firestore Map → MealPlan
  factory MealPlan.fromMap(Map<String, dynamic> map, String docId) {
    return MealPlan(
      id: docId,
      name: map["name"] ?? "",
      amount: "",
      unit: "",
      recipeName: map["recipeName"] ?? "",
      scheduledTime: map["scheduledTime"] != null
          ? DateTime.parse(map["scheduledTime"])
          : null,
      servings: map["servings"] ?? 1,
      // Deserialize ingredients list back to Ingredient objects
      ingredient: (map["ingredients"] as List<dynamic>? ?? [])
          .map((i) => Ingredient(
        name: i["name"] ?? "",
        amount: (i["amount"] as num?)?.toDouble() ?? 0,
        unit: i["unit"] ?? "",
      ))
          .toList(),
    );
  }
}