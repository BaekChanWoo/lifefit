import 'package:lifefit/model/user_model.dart';
import 'dart:developer';

// lage 대신 final 사용 -> 필드의 불변성을 보장
class FeedModel {
  final int id;
  final String title;
  final String content;
  final String name;
  final String category;
  final bool isMe;
  final int? imageId;
  final String? imagePath;
  final DateTime? createdAt;
  final UserModel? writer;

  FeedModel({
    required this.id,
    required this.title,
    required this.content,
    required this.name,
    required this.category,
    required this.isMe,
    this.imageId,
    this.imagePath,
    this.createdAt,
    this.writer,
  });

  factory FeedModel.parse(Map<String, dynamic> map) {
    return FeedModel(
      id: map['id'] as int? ?? 0, // null이면 0으로 대체
      title: map['title']?.toString() ?? '', // null이면 빈 문자열
      content: map['content']?.toString() ?? '', // null이면 빈 문자열
      name: map['name']?.toString() ?? '', // null이면 빈 문자열
      category: map['category']?.toString() ?? '기타', // null이면 '기타'
      isMe: map['is_me'] as bool? ?? false, // null이면 false
      imageId: map['image_id'] as int?,
      imagePath: map['image_path'] as String?,
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      writer: map['writer'] != null ? UserModel.parse(map['writer']) : null,
    );
  }

  FeedModel copyWith({
    int? id,
    String? title,
    String? content,
    String? name,
    String? category,
    bool? isMe,
    int? imageId,
    String? imagePath,
    DateTime? createdAt,
    UserModel? writer,
  }) {
    return FeedModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      name: name ?? this.name,
      category: category ?? this.category,
      isMe: isMe ?? this.isMe,
      imageId: imageId ?? this.imageId,
      imagePath: imagePath ?? this.imagePath,
      createdAt: createdAt ?? this.createdAt,
      writer: writer ?? this.writer,
    );
  }
}