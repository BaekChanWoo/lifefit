import 'package:flutter/material.dart';
import 'package:lifefit/model/meetup_model.dart';

/// 모집글 목록을 보여주는 위젯
class PostList extends StatelessWidget {
  final List<Post> posts;           //게시물 목록
  final VoidCallback onMorePressed; //More 버튼 클릭 시 실행
  final bool hasMore;               //보여줄 항목이 있는가

  const PostList({
    Key? key,
    required this.posts,
    required this.onMorePressed,
    required this.hasMore,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: posts.length + (hasMore ? 1 : 0), //More 버튼 포함 여부
      itemBuilder: (context, index) {
        if (index < posts.length) {
          final post = posts[index];

          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 3,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(post.description),
                ],
              ),
            ),
          );
        } else {
          // 마지막: More 버튼
          return Center(
            child: TextButton(
              onPressed: onMorePressed,
              child: const Text(
                'More +',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
