String timeAgo(DateTime? time) {
  if (time == null) return "";

  final diff = DateTime.now().difference(time);

  if (diff.inSeconds < 60) return "just now";
  if (diff.inMinutes < 60) return "${diff.inMinutes} min ago";
  if (diff.inHours < 24) return "${diff.inHours} hr ago";
  if (diff.inDays < 7) return "${diff.inDays} days ago";

  return "${time.day}/${time.month}/${time.year}";
}