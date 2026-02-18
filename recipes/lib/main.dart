import 'package:flutter/material.dart';
import 'recipe.dart';
import 'recipe_detail.dart';
import 'schedule_state.dart';
import 'scheduled_recipe.dart';

void main() {
  runApp(const RecipeApp());
}

class RecipeApp extends StatelessWidget {
  const RecipeApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = ThemeData();

    return MaterialApp(
      title: 'Recipe Calculator',
      theme: theme.copyWith(
        colorScheme: theme.colorScheme.copyWith(
          primary: Colors.grey,
          secondary: Colors.black,
        ),
      ),
      home: const MyHomePage(title: 'Recipe Calculator'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SafeArea(
        // 1. Wrap the existing ListView.builder in a Column
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 2. Add the new "Upcoming Meals" section
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
              child: Text(
                'Upcoming Meals',
                style: Theme
                    .of(context)
                    .textTheme
                    .titleLarge,
              ),
            ),
            // 3. Use ValueListenableBuilder to listen for schedule changes
            ValueListenableBuilder<List<ScheduledRecipe>>(
              valueListenable: ScheduleState.instance,
              builder: (context, scheduledItems, child) {
                // If there are no scheduled items, show a message
                if (scheduledItems.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 20.0),
                    child: Center(
                      child: Text(
                        'No meals scheduled yet.\nTap a recipe to plan a meal!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  );
                }
                // If there are items, show them in a horizontal list
                return SizedBox(
                  height: 120, // Give the horizontal list a fixed height
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: scheduledItems.length,
                    itemBuilder: (context, index) {
                      final item = scheduledItems[index];
                      return buildScheduledItemCard(context , item);
                    },
                  ),
                );
              },
            ),
            const Divider(indent: 16, endIndent: 16, height: 24),

            // 4. Add a title for the "All Recipes" section
            const Padding(
              padding: EdgeInsets.fromLTRB(16.0, 0, 16.0, 8.0),
              child: Text(
                'All Recipes',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            // 5. Put the original recipe list inside an Expanded widget
            Expanded(
              child: ListView.builder(
                itemCount: Recipe.samples.length,
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              RecipeDetail(recipe: Recipe.samples[index]),
                        ),
                      );
                    },
                    child: buildRecipeCard(Recipe.samples[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  void _showEditScheduleDialog(BuildContext context, ScheduledRecipe item) {
    DateTime selectedDate = item.date;
    int quantity = item.quantity;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final theme = Theme.of(context);
            return AlertDialog(
              title: Text('Edit "${item.recipe.label}"'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Date', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2101),
                      );
                      if (picked != null && picked != selectedDate) {
                        setState(() => selectedDate = picked);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(8.0)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                              '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}'),
                          Icon(Icons.calendar_month_outlined,
                              color: theme.primaryColor),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Quantity',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          if (quantity > 1) setState(() => quantity--);
                        },
                      ),
                      Text('$quantity', style: const TextStyle(fontSize: 18)),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () => setState(() => quantity++),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                    child: const Text('Cancel'),
                    onPressed: () => Navigator.of(context).pop()),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryColor,
                      foregroundColor: Colors.white),
                  child: const Text('Save'),
                  onPressed: () {
                    ScheduleState.instance.editScheduledRecipe(
                      id: item.id,
                      newDate: selectedDate,
                      newQuantity: quantity,
                    );
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, String scheduledItemId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content:
          const Text('Are you sure you want to remove this scheduled meal?'),
          actions: [
            TextButton(
                child: const Text('Cancel'),
                onPressed: () => Navigator.of(context).pop()),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
              onPressed: () {
                ScheduleState.instance.removeScheduledRecipe(scheduledItemId);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget buildScheduledItemCard(BuildContext context, ScheduledRecipe scheduledItem) {
    return Container(
      width: 250,
      margin: const EdgeInsets.only(right: 12.0),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${scheduledItem.date.year}-${scheduledItem.date.month.toString().padLeft(2, '0')}-${scheduledItem.date.day.toString().padLeft(2, '0')}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.only(right: 24.0),
                    child: Text(
                      scheduledItem.recipe.label,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Spacer(),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      'Quantity: ${scheduledItem.quantity}',
                      style: const TextStyle(
                          color: Colors.black54, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 20),
                onSelected: (value) {
                  if (value == 'edit') {
                    _showEditScheduleDialog(context, scheduledItem);
                  } else if (value == 'delete') {
                    _showDeleteConfirmDialog(context, scheduledItem.id);
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'edit',
                    child: ListTile(
                      leading: Icon(Icons.edit),
                      title: Text('Edit'),
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete),
                      title: Text('Delete'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  /// Builds each recipe card widget
  Widget buildRecipeCard(Recipe recipe) {
    return Card(
      margin: const EdgeInsets.all(10),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recipe Image
          ClipRRect(
            borderRadius:
            const BorderRadius.vertical(top: Radius.circular(12)),
            child: SizedBox(
              height: 200,
              width: double.infinity,
              child: Image.asset(
                recipe.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Recipe Title
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              recipe.label,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'palatino',
              ),
            ),
          ),
        ],
      ),
    );
  }
}