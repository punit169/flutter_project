import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/explore_screen.dart';
import 'screens/recipe_screen.dart';
import 'screens/cart_screen.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  int index = 0;

  final pages = [
    const ExploreScreen(),
    const RecipesScreen(),
    const CartScreen(),
  ];

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Food Recipe Hub",

      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),

      home: Scaffold(
        body: pages[index],

        bottomNavigationBar: BottomNavigationBar(
          currentIndex: index,

          onTap: (i) {
            setState(() {
              index = i;
            });
          },

          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.explore),
              label: "Explore",
            ),

            BottomNavigationBarItem(
              icon: Icon(Icons.restaurant),
              label: "Recipes",
            ),

            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart),
              label: "Cart",
            ),
          ],
        ),
      ),
    );
  }
}
