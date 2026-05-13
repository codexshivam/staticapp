class Comment {
  final String id;
  final String confessionId;
  final String authorId;
  final String content;
  final DateTime createdAt;
  final String? imageUrl;
  final bool isAuthor;

  const Comment({
    required this.id,
    required this.confessionId,
    required this.authorId,
    required this.content,
    required this.createdAt,
    this.imageUrl,
    this.isAuthor = false,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['\$id'] ?? json['id'] ?? '',
      confessionId: json['confessionId'] ?? '',
      authorId: json['authorId'] ?? '',
      content: json['content'] ?? '',
      createdAt: json['\$createdAt'] != null
          ? DateTime.parse(json['\$createdAt'])
          : (json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now()),
      imageUrl: json['imageUrl'],
      isAuthor: json['isAuthor'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'confessionId': confessionId,
      'authorId': authorId,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'imageUrl': imageUrl,
      'isAuthor': isAuthor,
    };
  }
}
