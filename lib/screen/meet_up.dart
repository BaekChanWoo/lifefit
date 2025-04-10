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

  //카테고리 현재값
  String selectedCategory = '러닝';
  //임시 데이터
  final List<Post> _allPosts = List.generate(
    10,
        (index) => Post(
      title: '함께 운동해요',
      description: '오전 7시 서울시 서초구',
      category: ['러닝', '클라이밍', '헬스', '사이클', '요가'][index % 5],
    ),
  );

  int _visiblePostCount = 3; //3개 게시글

  @override
  Widget build(BuildContext context) {
    // 선택된 카테고리 게시물 필터링
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
        backgroundColor: PRIMARY_COLOR,
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
                  selectedCategory = category; // 선택 시 상태 갱신
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