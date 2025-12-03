class Post {
  final String id;
  final DateTime createdAt;
  final String userId;
  final String username;
  final String content;
  final int likes;
  final int dislikes;
  final int angry;

  Post({
    required this.id,
    required this.createdAt,
    required this.userId,
    required this.username,
    required this.content,
    required this.likes,
    required this.dislikes,
    required this.angry,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']),
      userId: json['user_id'],
      username: json['username'],
      content: json['content'],
      likes: json['likes'],
      dislikes: json['dislikes'],
      angry: json['angry'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'username': username,
      'content': content,
    };
  }

  Map<String, dynamic> toCacheJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'user_id': userId,
      'username': username,
      'content': content,
      'likes': likes,
      'dislikes': dislikes,
      'angry': angry,
    };
  }
}