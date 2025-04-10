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
  final List<String> categories = ['러닝', '클라이밍', '헬스', '사이클', '요가'];

  // 현재 선택된 카테고리
  String selectedCategory = '러닝';

  // 각 카테고리에 대해 4개의 모집글을 자동 생성
  late final List<Post> _allPosts = [
    for (String category in categories)
      for (int i = 1; i <= 4; i++)
        Post(
          title: '운동메이트를 찾아요',
          description: '오전 7시 서울시 서초구',
          category: category,
        )
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
        backgroundColor: const Color(0xFFFFFFFF),
        title: const Text('라이프핏', style: TextStyle(color: Colors.black)),
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
            const SizedBox(height: 20),

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
