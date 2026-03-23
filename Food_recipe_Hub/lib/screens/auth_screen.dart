import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../providers/auth_provider.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final usernameController = TextEditingController();

  bool isLogin = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isLogin ? "Login" : "Register"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Username (only for signup)
            if (!isLogin)
              TextField(
                controller: usernameController,
                decoration:
                const InputDecoration(labelText: "Username"),
              ),

            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),

            TextField(
              controller: passwordController,
              obscureText: true,
              decoration:
              const InputDecoration(labelText: "Password"),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {
                if (isLogin) {
                  await ref.read(authProvider.notifier).login(
                    emailController.text,
                    passwordController.text,
                  );
                } else {
                  await ref.read(authProvider.notifier).signup(
                    emailController.text,
                    passwordController.text,
                    usernameController.text,
                  );
                }
              },
              child: Text(isLogin ? "Login" : "Register"),
            ),

            TextButton(
              onPressed: () {
                setState(() {
                  isLogin = !isLogin;
                });
              },
              child: Text(isLogin
                  ? "Create Account"
                  : "Already have an account? Login"),
            ),
          ],
        ),
      ),
    );
  }
}