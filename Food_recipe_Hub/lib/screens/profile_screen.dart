import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../providers/like_provider.dart';
import '../providers/bookmark_provider.dart';
import '../providers/user_provider.dart';
import '../providers/profile_state_provider.dart';
import '../utils/image_utils.dart';
import '../screens/bookmark_list_screen.dart';
import '../screens/liked_list_screen.dart';

// FIX: Converted from ConsumerWidget to ConsumerStatefulWidget
// so TextEditingController lives in State (not recreated on every build)
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  // FIX: Controller now lives here — created once, disposed properly
  late final TextEditingController _usernameController;
  bool _controllerInitialized = false;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }
  Widget _buildStatCard(String icon, String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(title, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
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
          if (user == null) return const Center(child: Text("No user"));

          // Seed controller text once after first load
          if (!_controllerInitialized) {
            _usernameController.text = user.username;
            _controllerInitialized = true;
          }

          // ✅ Centralised image logic in image_utils.dart
          // Handles null, base64, and legacy http URLs cleanly
          final imageProvider = getProfileImageProvider(user.photoPath, user.username);

          return SingleChildScrollView(
            child: Column(
              children: [
                // 🔥 TOP PROFILE HEADER
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.orange.shade400,
                        Colors.deepOrange.shade500,
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage: imageProvider,
                          ),

                          if (profileState is AsyncLoading)
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.4),
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(color: Colors.white),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      Text(
                        user.username,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),

                      Text(
                        user.email,
                        style: const TextStyle(color: Colors.white70),
                      ),

                      const SizedBox(height: 10),

                      GestureDetector(
                        onTap: () =>
                            ref.read(profileControllerProvider.notifier).pickImage(),
                        child: const Text(
                          "Change Photo",
                          style: TextStyle(color: Colors.white, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 🔥 STATS CARDS — tappable, navigate to full lists
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      // ── Liked card → LikedListScreen ──────────
                      // WHY GestureDetector not InkWell:
                      // GestureDetector works better on custom
                      // Container widgets. InkWell needs Material
                      // ancestor for the ripple effect to show.
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LikedListScreen(),
                            ),
                          ),
                          child: _buildStatCard(
                            "❤️",
                            "Liked",
                            likedIds.length.toString(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // ── Bookmark card → FavoritesListScreen ───
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const FavoritesListScreen(),
                            ),
                          ),
                          child: _buildStatCard(
                            "🔖",
                            "Bookmarks",
                            bookmarks.length.toString(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // 🔥 EDIT USERNAME
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _usernameController,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: "Update username",
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.check, color: Colors.green),
                          onPressed: () async {
                            final newUsername =
                            _usernameController.text.trim();

                            if (newUsername.isEmpty) return;

                            await ref
                                .read(profileControllerProvider.notifier)
                                .updateUsername(newUsername);

                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Updated!")),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // 🔥 LOGOUT BUTTON
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.logout),
                      label: const Text(
                        "Logout",
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () =>
                          ref.read(authProvider.notifier).logout(),
                    ),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }
}