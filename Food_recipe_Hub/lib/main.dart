import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/auth_provider.dart';
import 'screens/home_screen.dart';
import 'screens/auth_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await dotenv.load(fileName: ".env");
  runApp(
      const ProviderScope(
          child: MyApp(),
      ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(firebaseAuthProvider);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Food Recipe Hub",

      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),

      home: authState.when(
        data: (user) {
          if (user == null) {
            return const AuthScreen();
          } else {
            return const HomeScreen();
          }
        },
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (e, _) => Scaffold(
          body: Center(child: Text("Error: $e")),
        ),
      ),
    );
  }
}
