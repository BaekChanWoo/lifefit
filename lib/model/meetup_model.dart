import 'package:cloud_firestore/cloud_firestore.dart';

// 모집(Post) 모델 정의
class Post {
  final String title; // 제목
  final String description; // 설명
  final String category; // 운동 카테고리
  final String location; // 운동 장소
  final String dateTime; // 날짜 및 시간
  int currentPeople;// 현재 인원
  int maxPeople;  // 최대 인원

  final bool isMine; // 내가 작성한 글인지 확인
  List<String> applicants; // 신청자 목록
  final DateTime createdAt; // 생성 시간

  Post({
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    required this.dateTime,
    required this.currentPeople,
    required this.maxPeople,
    this.isMine=false,
    this.applicants = const [],
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Firestore 문서 변환하는 생성자
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      location: json['location'] ?? '',
      dateTime: json['dateTime'] ?? '',
      currentPeople: json['currentPeople'] ?? 0,
      maxPeople: json['maxPeople'] ?? 0,
      isMine: json['isMine'] ?? false,
      applicants: List<String>.from(json['applicants'] ?? []),
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),

    );
  }

  // Firestore에서 게시글을 읽어오는 함수
  static Future<List<Post>> fetchAllPosts() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('meetups')
        .orderBy('createdAt', descending: true)  //최신 글 먼저
        .get();

    return snapshot.docs.map((doc) => Post.fromJson(doc.data())).toList();
  }
}
