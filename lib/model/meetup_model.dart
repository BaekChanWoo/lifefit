import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  List<Map<String, String>> applicants;
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
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

    // 기존 applicants 파싱
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
          return {'uid': e.toString(), 'name': '익명'};
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
      applicants: parsedApplicants,
      authorName: json['authorName'] ?? '알 수 없음',
      authorId: json['authorId'] ?? '',
      isMine: json['authorId'] == currentUserId,
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
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
