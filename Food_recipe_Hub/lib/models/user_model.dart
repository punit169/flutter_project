class AppUser {
  final String uid;
  final String email;
  final String username;
  final String? photoPath;

  AppUser({
    required this.uid,
    required this.email,
    required this.username,
    this.photoPath,
  });

  factory AppUser.fromMap(Map<String, dynamic> data) {
    return AppUser(
      uid: data['uid'],
      email: data['email'],
      username: data['username'],
      photoPath: data['photoPath'],
    );
  }
}