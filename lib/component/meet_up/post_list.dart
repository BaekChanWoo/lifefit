import 'package:flutter/material.dart';
import 'package:lifefit/model/meetup_model.dart';
import 'apply_button.dart';
import 'apply_sheet.dart';

/// 게시글 리스트를 출력
class PostList extends StatefulWidget {
  final List<Post> posts;             // 현재 게시글
  final VoidCallback onMorePressed;   // More 버튼 클릭 시 호출
  final bool hasMore;                 // 추가 글 있는지

  const PostList({
    Key? key,
    required this.posts,
    required this.onMorePressed,
    required this.hasMore,
  }) : super(key: key);

  @override
  State<PostList> createState() => _PostListState();
}

class _PostListState extends State<PostList> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.posts.length + (widget.hasMore ? 1 : 0),

      itemBuilder: (context, index) {
        if (index < widget.posts.length) {
          final post = widget.posts[index]; // 현재 게시글

          return Card(
            shape: ContinuousRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
            margin: const EdgeInsets.symmetric(vertical: 5),
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 제목 표시
                  Text(
                    post.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  // 설명 표시
                  Text(post.description),

                  const SizedBox(height: 12),

                  // 인원 수 신청 버튼 나란히 배치
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 정원 표시
                      Text(
                        '정원: ${post.currentPeople}명 / ${post.maxPeople}명',
                      ),

                      // 신청 버튼
                      ApplyButton(
                        isApplied: post.currentPeople >= post.maxPeople,
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                            ),
                            builder: (_) => ApplySheet(
                              post: post,
                              onApplied: () {
                                // 시트에서 인원이 증가했을 때 화면 갱신
                                setState(() {});
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        } else {
          // 게시글 끝났을 때 More 버튼 출력
          return Center(
            child: TextButton(
              onPressed: widget.onMorePressed,
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
