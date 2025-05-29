class CommentModel {
  final int id;
  final int userId;
  final String userName;
  final String content;
  final DateTime createdAt;

  CommentModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.content,
    required this.createdAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) => CommentModel(
    id: json['id'],
    userId: json['user_id'],
    userName: json['user_name'],
    content: json['content'],
    createdAt: DateTime.parse(json['created_at']),
  );
}