import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/auth_provider.dart';
import '../providers/like_provider.dart';
import '../providers/bookmark_provider.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;
    final likedIds = ref.watch(likeProvider);
    final bookmarks = ref.watch(favoritesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 👤 User Info
            Text(
              user?.email ?? "No Email",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            // ❤️ Likes count
            Text("❤️ Liked Recipes: ${likedIds.length}"),

            const SizedBox(height: 10),

            // 🔖 Bookmarks count
            Text("🔖 Bookmarks: ${bookmarks.length}"),

            const SizedBox(height: 30),

            // 🚪 Logout
            ElevatedButton(
              onPressed: () {
                ref.read(authProvider.notifier).logout();
              },
              child: const Text("Logout"),
            ),
          ],
        ),
      ),
    );
  }
}