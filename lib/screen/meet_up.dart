import 'package:flutter/material.dart';
import '../component/meet_up/category_select.dart';
import '../component/meet_up/create_post.dart';
import '../component/meet_up/post_list.dart';
import '../const/colors.dart';
import '../model/meetup_model.dart';

class MeetUpScreen extends StatefulWidget {
  const MeetUpScreen({Key? key}) : super(key: key);

  @override
  State<MeetUpScreen> createState() => _MeetUpScreenState();
}


class _MeetUpScreenState extends State<MeetUpScreen> {
  //카테고리 목록
  final List<String> categories = [
    '전체',
    '러닝',
    '헬스',
    '요가',
    '필라테스',
    '사이클',
    '클라이밍',
    '농구'
  ];

  //현재 선택된 카테고리 상태
  String selectedCategory = '전체';

  List<Post> _allPosts = [];
  bool _isLoading = true; // 로딩 상태 관리
  int _visiblePostCount = 3;

  @override
  void initState() {
    super.initState();
    _loadPosts(); // Firestore에서 모집글 불러오기
  }

  // Firestore에서 데이터 가져오는 함수
  Future<void> _loadPosts() async {
    try {
      final posts = await Post.fetchAllPosts();
      print('✅ Firestore에서 가져온 게시글 수: ${posts.length}');
      setState(() {
        _allPosts = posts;
        _isLoading = false;
      });
    } catch (e) {
      print('게시글 불러오기 실패: $e');
      setState(() => _isLoading = false);
    }

  }

  @override
  Widget build(BuildContext context) {
    // 현재 선택된 카테고리에 해당하는 게시글 필터링
    final filteredPosts = _allPosts
        .where((post) =>
    selectedCategory == '전체' || post.category == selectedCategory)
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
        title: const Text(
            '번개', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500)),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            //child: Icon(Icons.menu, color: Colors.black),
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // 로딩 중
          : Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            CategorySelector(
              categories: categories,
              selectedCategory: selectedCategory,
              onCategorySelected: (category) {
                setState(() {
                  selectedCategory = category;
                  _visiblePostCount = 3;
                });
              },
            ),
            const SizedBox(height: 10),

            //게시글 리스트
            Expanded(
              child: PostList(
                posts: filteredPosts,
                hasMore: hasMore,
                onMorePressed: () {
                  setState(() {
                    _visiblePostCount += 3;
                  });
                },
                onRefreshRequested: _loadPosts,
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

//        글 등록 후 목록 새로고침
          if (newPost != null) {
            await _loadPosts();  //irestore에서 최신 데이터 다시 가져오기
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation
          .startFloat, // 왼쪽 하단에 위치
    );
  }
}
