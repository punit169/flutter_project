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
  bool isLoading = false;

  String? validateInputs() {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final username = usernameController.text.trim();

    if (!email.contains("@") || !email.contains(".")) {
      return "Enter a valid email";
    }

    if (password.length < 6) {
      return "Password must be at least 6 characters";
    }

    if (!isLogin && username.isEmpty) {
      return "Username cannot be empty";
    }

    return null;
  }

  Future<void> handleAuth() async {
    final error = validateInputs();

    if (error != null) {
      showMessage(error);
      return;
    }

    setState(() => isLoading = true);

    try {
      if (isLogin) {
        await ref.read(authProvider.notifier).login(
          emailController.text.trim(),
          passwordController.text.trim(),
        );
      } else {
        await ref.read(authProvider.notifier).signup(
          emailController.text.trim(),
          passwordController.text.trim(),
          usernameController.text.trim(),
        );
      }
    } catch (e) {
      showMessage(e.toString().replaceAll("Exception: ", ""));
    }

    setState(() => isLoading = false);
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  InputDecoration buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Card(
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 🔥 Title
                    Text(
                      isLogin ? "Welcome Back 👋" : "Create Account 🚀",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 🔥 Username
                    if (!isLogin)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: TextField(
                          controller: usernameController,
                          decoration: buildInputDecoration(
                              "Username", Icons.person),
                        ),
                      ),

                    // 🔥 Email
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: TextField(
                        controller: emailController,
                        decoration:
                        buildInputDecoration("Email", Icons.email),
                      ),
                    ),

                    // 🔥 Password
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration:
                        buildInputDecoration("Password", Icons.lock),
                      ),
                    ),

                    // 🔥 Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: handleAuth,
                        child: Text(
                          isLogin ? "Login" : "Register",
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // 🔥 Toggle
                    TextButton(
                      onPressed: () {
                        setState(() {
                          isLogin = !isLogin;
                        });
                      },
                      child: Text(
                        isLogin
                            ? "Don't have an account? Register"
                            : "Already have an account? Login",
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}