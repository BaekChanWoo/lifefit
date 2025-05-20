import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String? docId;
  final String title;
  final String description;
  final String category;
  final String location;
  final String dateTime;
  int currentPeople;
  int maxPeople;
  final bool isMine;
  List<Map<String, String>> applicants; // ✅ 수정됨
  final DateTime createdAt;
  final String authorName;
  final String authorId;

  Post({
    this.docId,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    required this.dateTime,
    required this.currentPeople,
    required this.maxPeople,
    this.isMine = false,
    this.applicants = const [],
    DateTime? createdAt,
    required this.authorName,
    required this.authorId,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Post.fromJson(Map<String, dynamic> json, [String? id]) {
    // 신청자 파싱 처리 (안전하게 map으로 변환)
    List<Map<String, String>> parsedApplicants = [];
    if (json['applicants'] != null) {
      final rawList = json['applicants'] as List;
      parsedApplicants = rawList.map((e) {
        if (e is Map) {
          return {
            'uid': e['uid']?.toString() ?? '',
            'name': e['name']?.toString() ?? '',
          };
        } else {
          return {'uid': e.toString(), 'name': '익명'}; // 혹시 문자열로 저장된 예전 데이터 대비
        }
      }).toList();
    }

    return Post(
      docId: id,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      location: json['location'] ?? '',
      dateTime: json['dateTime'] ?? '',
      currentPeople: json['currentPeople'] ?? 0,
      maxPeople: json['maxPeople'] ?? 0,
      isMine: json['isMine'] ?? false,
      applicants: parsedApplicants,
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      authorName: json['authorName'] ?? '알 수 없음',
      authorId: json['authorId'] ?? '',
    );
  }

  Future<void> deleteFromFirestore() async {
    if (docId != null) {
      await FirebaseFirestore.instance
          .collection('meetups')
          .doc(docId)
          .delete();
    }
  }

  static Future<List<Post>> fetchAllPosts() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('meetups')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => Post.fromJson(doc.data(), doc.id))
        .toList();
  }
}
