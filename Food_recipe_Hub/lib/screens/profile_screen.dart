import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../providers/like_provider.dart';
import '../providers/bookmark_provider.dart';

import '../providers/user_provider.dart';
import '../providers/profile_state_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);
    final likedIds = ref.watch(likeProvider);
    final bookmarks = ref.watch(favoritesProvider);
    final profileState = ref.watch(profileControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),

        error: (e, _) => Center(child: Text("Error: $e")),

        data: (user) {
          if (user == null) {
            return const Center(child: Text("No user"));
          }

          ImageProvider imageProvider;

          if (user.photoPath != null &&
              File(user.photoPath!).existsSync()) {
            imageProvider = FileImage(File(user.photoPath!));
          } else {
            imageProvider = NetworkImage(
              "https://ui-avatars.com/api/?name=${user.username}&background=ff9800&color=fff",
            );
          }
          final usernameController = TextEditingController(text: user.username);
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔥 PROFILE IMAGE
                GestureDetector(
                  onTap: () {
                    ref.read(profileControllerProvider.notifier).pickImage();
                  },
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          CircleAvatar(
                            radius: 45,
                            backgroundImage: imageProvider,
                          ),

                          if (profileState is AsyncLoading)
                            Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      profileState.when(
                        data: (_) => const Text(
                          "Tap to change profile",
                          style: TextStyle(color: Colors.grey),
                        ),
                        loading: () => const Text(
                          "Uploading...",
                          style: TextStyle(color: Colors.orange),
                        ),
                        error: (e, _) => Text(
                          "Error: $e",
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                // Username
                Text(
                  user.username,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: usernameController,
                        decoration: const InputDecoration(
                          labelText: "Edit Username",
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.check),
                      onPressed: () async {
                        final newUsername = usernameController.text.trim();

                        if (newUsername.isEmpty) return;

                        await ref
                            .read(profileControllerProvider.notifier)
                            .updateUsername(newUsername);
                      },
                    ),
                  ],
                ),
                // 👤 USER INFO
                Text(
                  user.email,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                Text("❤️ Liked Recipes: ${likedIds.length}"),
                const SizedBox(height: 10),
                Text("🔖 Bookmarks: ${bookmarks.length}"),

                const SizedBox(height: 30),

                ElevatedButton(
                  onPressed: () {
                    ref.read(authProvider.notifier).logout();
                  },
                  child: const Text("Logout"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}