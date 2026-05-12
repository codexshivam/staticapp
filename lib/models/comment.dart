class Comment {
  final String id;
  final String authorName;
  final String authorAvatar;
  final String content;
  final String timestamp;
  final String? imageUrl; // For optional image support UI
  final bool isAuthor;

  const Comment({
    required this.id,
    required this.authorName,
    required this.authorAvatar,
    required this.content,
    required this.timestamp,
    this.imageUrl,
    this.isAuthor = false,
  });
}
