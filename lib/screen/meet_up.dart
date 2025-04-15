import 'package:flutter/material.dart';

import '../component/meet_up/category_select.dart';
import '../component/meet_up/post_list.dart';
import '../const/colors.dart';
import '../model/meetup_model.dart';

class MeetUpScreen extends StatefulWidget {
  const MeetUpScreen({Key? key}) : super(key: key);

  @override
  State<MeetUpScreen> createState() => _MeetUpScreenState();
}

class _MeetUpScreenState extends State<MeetUpScreen> {
  // 카테고리 목록
  final List<String> categories = ['러닝', '헬스', '요가', '필라테스', '사이클', '클라이밍', '농구' ];

  // 현재 선택된 카테고리
  String selectedCategory = '러닝';

  // 각 카테고리에 대해 4개의 모집글을 자동 생성
  final List<Post> _allPosts = [
    // 러닝 카테고리 4개 생성
    ...List.generate(4, (index) => Post(
      title: '러닝 모임 함께해요',
      description: '아침 러닝, 초보자 환영!',
      category: '러닝',
      location: '한강',
      dateTime: '2025.04.11.Fri. AM 07:30',
      currentPeople: 3,
      maxPeople: 5,
    )),

    // 클라이밍 카테고리 4개 생성
    ...List.generate(4, (index) => Post(
      title: '헬스 초보 환영',
      description: '온수역 헬스장에서 같이 운동해요',
      category: '헬스',
      location: '온수역 헬스장',
      dateTime: '2025.04.11.Fri. AM 07:30',
      currentPeople: 2,
      maxPeople: 4,
    )),
  ];


  int _visiblePostCount = 3; // 처음에 보이는 게시글 수

  @override
  Widget build(BuildContext context) {
    // 선택된 카테고리에 해당하는 게시물만 필터링
    final filteredPosts = _allPosts
        .where((post) => post.category == selectedCategory)
        .take(_visiblePostCount)
        .toList();

    final hasMore = _allPosts
        .where((post) => post.category == selectedCategory)
        .length >
        _visiblePostCount;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xFFFFFFFF),
        title: const Text('번개', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.menu, color: Colors.black),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // 상단 카테고리 선택 위젯
            CategorySelector(
              categories: categories,
              selectedCategory: selectedCategory,
              onCategorySelected: (category) {
                setState(() {
                  selectedCategory = category;
                  _visiblePostCount = 3; // 카테고리 바꿀 때도 초기화
                });
              },
            ),
            const SizedBox(height: 10),

            // 모집 카드 리스트
            Expanded(
              child: PostList(
                posts: filteredPosts,
                hasMore: hasMore,
                onMorePressed: () {
                  setState(() {
                    _visiblePostCount += 3;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
