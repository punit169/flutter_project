import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cart.dart';
import '../providers/cart_provider.dart';
import '../providers/meal_plan_provider.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {

  final Map<int, bool> checkedItems = {};

  @override
  Widget build(BuildContext context) {

    final cartItems = ref.watch(cartProvider);
    final mealPlans = ref.watch(mealPlanProvider);

    final scheduledIngredients = <CartItem>[];

    for (var plan in mealPlans) {
      for (var ingredient in plan.ingredient) {
        scheduledIngredients.add(
          CartItem(
            name: ingredient.name,
            amount: ingredient.amount.toString(),
            unit: ingredient.unit,
            recipeName: plan.recipeName,
            scheduledTime: plan.scheduledTime,
          ),
        );
      }
    }

    final allItems = [...cartItems, ...scheduledIngredients];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Shopping List"),
      ),

      body: allItems.isEmpty
          ? const Center(child: Text("Cart is empty"))
          : ListView.builder(
        itemCount: allItems.length,
        itemBuilder: (context, index) {

          final item = allItems[index];
          final isChecked = checkedItems[index] ?? false;

          return Card(
            margin: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 4,
            ),
            child: CheckboxListTile(

              value: isChecked,

              title: Text(
                item.name,
                style: TextStyle(
                  fontSize: 16,
                  decoration: isChecked
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
              ),

              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    "${item.amount} ${item.unit}",
                    style: const TextStyle(fontSize: 12),
                  ),

                  if (item.recipeName != null)
                    Text(
                      "Recipe: ${item.recipeName} , Time: ${item.scheduledTime?.toString() ?? "Not Scheduled"}",
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                ],
              ),

              onChanged: (value) {
                setState(() {
                  checkedItems[index] = value ?? false;
                });
              },

              secondary: index < cartItems.length
                  ? IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  ref
                      .read(cartProvider.notifier)
                      .removeItem(index);
                },
              )
                  : null,
            ),
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {

          ref.read(cartProvider.notifier).clearCart();
          ref.read(mealPlanProvider.notifier).clearMeals();

          setState(() {
            checkedItems.clear();
          });

        },
        child: const Icon(Icons.delete_sweep),
      ),
    );
  }
}