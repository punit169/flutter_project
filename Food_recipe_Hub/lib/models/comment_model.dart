import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String userId;
  final String username;
  final String? photoPath;
  final String text;
  final int likes;
  final List<String> likedBy;
  final DateTime? createdAt;

  Comment({
    required this.id,
    required this.userId,
    required this.username,
    this.photoPath,
    required this.text,
    required this.likes,
    required this.likedBy,
    this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json, String id) {
    return Comment(
      id: id,
      userId: json["userId"],
      username: json["username"],
      photoPath: json["photoPath"],
      text: json["text"],
      likes: json["likes"] ?? 0,
      likedBy: List<String>.from(json["likedBy"] ?? []),
      createdAt: (json["createdAt"] as Timestamp?)?.toDate(),
    );
  }
}