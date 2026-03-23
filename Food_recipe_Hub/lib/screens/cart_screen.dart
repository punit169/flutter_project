import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/cart_provider.dart';
import '../providers/meal_plan_provider.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {

  final Map<String, bool> checkedItems = {};

  @override
  Widget build(BuildContext context) {

    final cartItems = ref.watch(cartProvider.notifier).mergedItems;
    final mealPlans = ref.watch(mealPlanProvider);
    final sortedMeals = [...mealPlans];


    sortedMeals.sort(
          (a, b) => (a.scheduledTime ?? DateTime.now())
          .compareTo(b.scheduledTime ?? DateTime.now()),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Shopping List"),
      ),

      body: (cartItems.isEmpty && mealPlans.isEmpty)
          ? const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

            Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: Colors.grey,
          ),

          SizedBox(height: 20),

          Text(
            "No items in the cart.",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          ],
        ),
      ) :ListView(
        children: [

          // SCHEDULED RECIPES
          ...sortedMeals.map((plan) {

            final time = TimeOfDay.fromDateTime(plan.scheduledTime ?? DateTime.now());
            final scheduled = plan.scheduledTime ?? DateTime.now();
            final date =
                "${scheduled.day}/${scheduled.month}/${scheduled.year}";
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    "${plan.recipeName} - ${plan.servings} Servings"
                        "($date ${time.format(context)})",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                ...plan.ingredient.map((ingredient) {

                  final key = "${plan.recipeName}_${ingredient.name}";

                  return CheckboxListTile(
                    value: checkedItems[key] ?? false,

                    title: Text(
                      "${ingredient.name}",
                      style: TextStyle(
                        decoration:
                        (checkedItems[key] ?? false)
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),

                    subtitle: Text("${ingredient.amount*plan.servings} ${ingredient.unit}"),

                    onChanged: (value) {
                      setState(() {
                        checkedItems[key] = value ?? false;
                      });
                    },
                  );
                }),
              ],
            );
          }),

          // MANUAL CART ITEMS GROUPED BY RECIPE
          if (cartItems.isNotEmpty) ...[
            ...{for (var item in cartItems) item.recipeName}.map((recipeName) {

              final itemsForRecipe = cartItems.where((item) => item.recipeName == recipeName).toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      recipeName ,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ...itemsForRecipe.map((item) {
                    final isChecked = checkedItems[item.name] ?? false;
                    return CheckboxListTile(
                      value: isChecked,
                      title: Text(
                        "${item.name} ",
                        style: TextStyle(
                          decoration: isChecked ? TextDecoration.lineThrough : TextDecoration.none,
                        ),
                      ),
                      subtitle: Text("${item.amount} ${item.unit}"),
                      onChanged: (value) {
                        setState(() {
                          checkedItems[item.name] = value ?? false;
                        });
                      },
                    );
                  }),
                ],
              );
            }),
          ],
        ],
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