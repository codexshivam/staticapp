class Comment {
  final String id;
  final String confessionId;
  final String authorId;
  final String authorName;
  final String authorAvatar;
  final String content;
  final String timestamp;
  final String? imageUrl;
  final bool isAuthor;

  const Comment({
    required this.id,
    required this.confessionId,
    required this.authorId,
    required this.authorName,
    required this.authorAvatar,
    required this.content,
    required this.timestamp,
    this.imageUrl,
    this.isAuthor = false,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['\$id'] ?? json['id'] ?? '',
      confessionId: json['confessionId'] ?? '',
      authorId: json['authorId'] ?? '',
      authorName: json['authorName'] ?? '',
      authorAvatar: json['authorAvatar'] ?? '',
      content: json['content'] ?? '',
      timestamp: json['timestamp'] ?? '',
      imageUrl: json['imageUrl'],
      isAuthor: json['isAuthor'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'confessionId': confessionId,
      'authorId': authorId,
      'authorName': authorName,
      'authorAvatar': authorAvatar,
      'content': content,
      'timestamp': timestamp,
      'imageUrl': imageUrl,
      'isAuthor': isAuthor,
    };
  }
}
