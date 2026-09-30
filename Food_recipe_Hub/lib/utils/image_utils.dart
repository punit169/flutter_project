import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────
// WHY this utility exists:
// Profile photos are stored as Base64 strings in Firestore.
// Base64 strings need to be decoded back to raw bytes before
// Flutter can render them using MemoryImage.
//
// We centralise this logic here so all 3 screens
// (ProfileScreen, ExploreScreen, RecipeDetailScreen)
// use the same consistent approach instead of
// duplicating the if/else logic everywhere.
// ─────────────────────────────────────────────────────────

/// Returns the correct ImageProvider for a given photoPath value.
/// photoPath can be:
///   - null           → show generated avatar from ui-avatars.com
///   - base64 string  → decode and show with MemoryImage
///   - http URL       → show with NetworkImage (legacy/future support)
ImageProvider getProfileImageProvider(String? photoPath, String username) {
  if (photoPath == null || photoPath.isEmpty) {
    // No photo set — show auto-generated avatar with user's initials
    return NetworkImage(
      "https://ui-avatars.com/api/?name=${Uri.encodeComponent(username)}&background=ff9800&color=fff",
    );
  }

  if (photoPath.startsWith("http")) {
    // Legacy support: if somehow a URL is stored (e.g. old records)
    return NetworkImage(photoPath);
  }

  // Base64 encoded image — decode to bytes and use MemoryImage
  try {
    final Uint8List bytes = base64Decode(photoPath);
    return MemoryImage(bytes);
  } catch (_) {
    // If decoding fails for any reason, fall back to avatar
    return NetworkImage(
      "https://ui-avatars.com/api/?name=${Uri.encodeComponent(username)}&background=ff9800&color=fff",
    );
  }
}