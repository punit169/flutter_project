class AppUser {
  final String uid;
  final String email;
  final String username;
  final String? photoUrl;

  AppUser({
    required this.uid,
    required this.email,
    required this.username,
    this.photoUrl,
  });
}