import 'package:flutter/material.dart';
import '../component/meet_up/category_select.dart';
import '../component/meet_up/create_post.dart';
import '../component/meet_up/post_list.dart';
import '../const/colors.dart';
import '../model/meetup_model.dart';

// 카테고리별 아이콘을 반환하는 함수
IconData getCategoryIcon(String category) {
  switch (category) {
    case '러닝':
      return Icons.directions_run;
    case '헬스':
      return Icons.fitness_center;
    case '요가':
      return Icons.self_improvement;
    case '필라테스':
      return Icons.accessibility_new;
    case '사이클':
      return Icons.directions_bike;
    case '클라이밍':
      return Icons.terrain;
    case '농구':
      return Icons.sports_basketball;
    default:
      return Icons.sports; // 기본 스포츠 아이콘
  }
}

class MeetUpScreen extends StatefulWidget {
  const MeetUpScreen({Key? key}) : super(key: key);

  @override
  State<MeetUpScreen> createState() => _MeetUpScreenState();
}

class _MeetUpScreenState extends State<MeetUpScreen> {
  //카테고리 목록
  final List<String> categories = ['러닝', '헬스', '요가', '필라테스', '사이클', '클라이밍', '농구'];

  //현재 선택된 카테고리 상태
  String selectedCategory = '러닝';

  // 게시글 하드코딩
  final List<Post> _allPosts = [
    ...List.generate(4, (index) => Post(
      title: '러닝 모임 함께해요',
      description: '아침 러닝, 초보자 환영!',
      category: '러닝',
      location: '한강',
      dateTime: '2025.04.11.Fri. AM 07:30',
      currentPeople: 3,
      maxPeople: 5,
      isMine: true,
      applicants: [],
    )),
    ...List.generate(4, (index) => Post(
      title: '헬스 초보 환영',
      description: '온수역 헬스장에서 같이 운동해요',
      category: '헬스',
      location: '온수역 헬스장',
      dateTime: '2025.04.11.Fri. AM 07:30',
      currentPeople: 2,
      maxPeople: 4,
      isMine: true,
      applicants: [],
    )),
  ];

  // 한 번에 보일 게시글 수
  int _visiblePostCount = 3;

  @override
  Widget build(BuildContext context) {
    // 현재 선택된 카테고리에 해당하는 게시글 필터링
    final filteredPosts = _allPosts
        .where((post) => post.category == selectedCategory)
        .take(_visiblePostCount)
        .toList();

    // 더 불러올 게시글이 있는지 여부 판단
    final hasMore = _allPosts
        .where((post) => post.category == selectedCategory)
        .length > _visiblePostCount;

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
            // 카테고리 선택 버튼 리스트 (아이콘 포함)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: categories.map((category) {
                  final isSelected = category == selectedCategory;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          selectedCategory = category; // 카테고리 선택 시 상태 변경
                          _visiblePostCount = 3; // 글 수 초기화
                        });
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: isSelected ? PRIMARY_COLOR : Colors.grey.shade200,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      child: Row(
                        children: [
                          // 카테고리 아이콘
                          Icon(
                            getCategoryIcon(category),
                            size: 18,
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                          const SizedBox(width: 6),
                          // 카테고리 텍스트
                          Text(
                            category,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 10),

            //게시글 리스트
            Expanded(
              child: PostList(
                posts: filteredPosts,
                hasMore: hasMore,
                onMorePressed: () {
                  setState(() {
                    _visiblePostCount += 3; // More 버튼 클릭 시 게시글 추가
                  });
                },
              ),
            ),
          ],
        ),
      ),

      // 글쓰기 버튼
      floatingActionButton: FloatingActionButton(
        backgroundColor: PRIMARY_COLOR,
        child: const Icon(Icons.add, color: Colors.black),
        onPressed: () async {
          // 글쓰기 다이얼로그 표시
          final newPost = await showDialog<Post>(
            context: context,
            builder: (context) => const CreatePost(),
          );

          if (newPost != null) {
            setState(() {
              _allPosts.insert(0, newPost); // 새 글 가장 위에 추가
            });
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat, // 왼쪽 하단에 위치
    );
  }
}