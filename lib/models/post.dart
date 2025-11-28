class Post {
  final String id;
  final String userId;
  final String username;
  final String? avatarUrl;
  final String content;
  final String? imageUrl;
  final int likesCount;
  final bool isLiked;
  final DateTime createdAt;

  Post({
    required this.id,
    required this.userId,
    required this.username,
    this.avatarUrl,
    required this.content,
    this.imageUrl,
    this.likesCount = 0,
    this.isLiked = false,
    required this.createdAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      userId: json['user_id'],
      username: json['username'],
      avatarUrl: json['avatar_url'],
      content: json['content'],
      imageUrl: json['image_url'],
      likesCount: json['likes_count'] ?? 0,
      isLiked: json['is_liked'] == 1 || json['is_liked'] == true,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

