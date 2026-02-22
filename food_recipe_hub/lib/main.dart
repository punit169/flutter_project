import 'package:flutter/material.dart';
import 'theme.dart';
import 'home.dart';

void main() {
  // 1
  runApp(const FoodSocial());
}

class FoodSocial extends StatelessWidget {
  // 2
  const FoodSocial({super.key});
  @override
  Widget build(BuildContext context) {
    final theme = FoodSTheme.dark();

    // 3
    return MaterialApp(
      theme: theme,
      title: 'Food_social',
      // 4
      home: const Home(),
    );
  }
}
