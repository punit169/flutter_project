import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'auth_provider.dart';

final userProvider = StreamProvider<AppUser?>((ref) {
  final authState = ref.watch(firebaseAuthProvider);

  return authState.when(
    data: (firebaseUser) {
      if (firebaseUser == null) {
        return Stream.value(null);
      }

      return FirebaseFirestore.instance
          .collection("users")
          .doc(firebaseUser.uid)
          .snapshots()
          .map((doc) {
        final data = doc.data();

        if (data == null) return null;

        return AppUser(
          uid: firebaseUser.uid,
          email: firebaseUser.email ?? "",
          username: data["username"] ?? "User",
          photoPath: data["photoPath"],
        );
      });
    },
    loading: () => const Stream.empty(),
    error: (_, __) => const Stream.empty(),
  );
});