import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/auth_provider.dart';
import 'screens/home_screen.dart';
import 'screens/auth_screen.dart';
void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Food Recipe Hub",

      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),

      home: user == null ? AuthScreen() : HomeScreen(),
    );
  }
}
