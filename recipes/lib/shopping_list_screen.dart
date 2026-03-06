import 'package:flutter/material.dart';
import 'scheduled_recipe.dart';
import 'schedule_state.dart';

class ShoppingListScreen extends StatelessWidget {
  const ShoppingListScreen({Key? key}) : super(key: key);

  Map<String, double> _createShoppingList(List<ScheduledRecipe> scheduledItems) {
    final shoppingList = <String, double>{};

    for (final scheduledItem in scheduledItems) {
      for (final ingredient in scheduledItem.recipe.ingredients) {
        final key = '${ingredient.measure ?? ''} ${ingredient.name}'.trim();
        final quantity = ingredient.quantity * scheduledItem.quantity;

        // Add the quantity to the existing entry or create a new one
        shoppingList.update(key, (value) => value + quantity, ifAbsent: () => quantity);
      }
    }
    return shoppingList;
  }

  @override
  Widget build(BuildContext context) {
    final scheduledItems = ScheduleState.instance.value;
    final shoppingList = _createShoppingList(scheduledItems);

    final sortedKeys = shoppingList.keys.toList()..sort();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping List'),
      ),
      body: scheduledItems.isEmpty
          ? const Center(
        child: Text(
          'Schedule some meals to see your shopping list!',
          style: TextStyle(color: Colors.grey, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: sortedKeys.length,
        itemBuilder: (context, index) {
          final key = sortedKeys[index];
          final quantity = shoppingList[key]!;
          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 6.0),
            child: ListTile(
              title: Text(
                key,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              trailing: Text(
                // Format the quantity nicely
                '${quantity.toStringAsFixed(2).replaceAll(RegExp(r'\.?0*$'), '')}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          );
        },
      ),
    );
  }
}
