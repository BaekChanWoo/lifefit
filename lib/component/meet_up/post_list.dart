import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lifefit/const/colors.dart';
import 'package:lifefit/model/meetup_model.dart';
import 'applicant_list.dart';
import 'apply_button.dart';
import 'apply_sheet.dart';
import 'create_post.dart';

//게시글 리스트를 출력
class PostList extends StatefulWidget {
  final List<Post> posts;
  final VoidCallback onMorePressed;
  final bool hasMore;
  final VoidCallback? onRefreshRequested; // 콜백 추가

  const PostList({
    Key? key,
    required this.posts,
    required this.onMorePressed,
    required this.hasMore,
    this.onRefreshRequested, // 콜백 받아오기
  }) : super(key: key);

  @override
  State<PostList> createState() => _PostListState();
}

class _PostListState extends State<PostList> {
  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? 'guest';
    // 최신 글을 위로 정렬
    final sortedPosts = List<Post>.from(widget.posts)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    if (widget.posts.isEmpty) {
      return const Center(
        child: Text(
          '현재 게시글이 없습니다.',
          style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w700),
        ),
      );
    }

    return RefreshIndicator(
        onRefresh: () async {
      if (widget.onRefreshRequested != null) {
        widget.onRefreshRequested!(); // 상위에서 전달된 콜백 실행
      }
    },
    child: ListView.separated(
      itemCount: sortedPosts.length + (widget.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < sortedPosts.length) {
          final post = sortedPosts[index];

          return Card(
            shape: ContinuousRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
            margin: const EdgeInsets.symmetric(vertical: 6),
            color: Colors.white,
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            post.title,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '작성자: ${post.authorName}',
                            style: const TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Icon(Icons.place, size: 16, color: Colors.grey),
                          const SizedBox(width: 5),
                          Text(post.location, style: const TextStyle(color: Colors.grey)),
                          const SizedBox(width: 16),
                          const Icon(Icons.access_time, size: 16, color: Colors.grey),
                          const SizedBox(width: 5),
                          Text(post.dateTime, style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('정원: ${post.currentPeople}명 / ${post.maxPeople}명'),
                          ApplyButton(
                            isApplied: post.applicants.any((a) => a['uid'] == currentUserId),
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
                                    widget.onRefreshRequested?.call();
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
                if (post.isMine == true)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: PopupMenuButton<String>(
                      onSelected: (value) async {
                        if (value == 'edit') {
                          final updatedPost = await showDialog<Post>(
                            context: context,
                            builder: (_) => CreatePost(existingPost: post),
                          );
                          if (updatedPost != null) {
                            widget.onRefreshRequested?.call();
                          }
                        } else if (value == 'delete') {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('삭제'),
                              content: const Text('해당 게시글을 삭제하시겠습니까?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(false),
                                  child: const Text('취소'),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.of(context).pop(true),
                                  child: const Text('삭제'),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            await post.deleteFromFirestore();
                            widget.onRefreshRequested?.call();
                          }
                        }
                        if (value == 'viewApplicants') {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                            ),
                            builder: (_) => ApplicantList(post: post),
                          );
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(value: 'edit', child: Text('수정')),
                        PopupMenuItem(value: 'delete', child: Text('삭제')),
                        PopupMenuItem(value: 'viewApplicants', child: Text('신청자 보기')),
                      ],
                      icon: const Icon(Icons.more_vert, size: 20),
                    ),
                  ),
              ],
            ),
          );
        } else {
          // More + 버튼
          return Center(
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFCCFF99),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
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
      separatorBuilder: (context, index) => const Divider(
        color: Color(0xFFE0E0E0),
        thickness: 1,
        height: 16,
        indent: 16,
        endIndent: 16,
      ),
    ));
  }
}
