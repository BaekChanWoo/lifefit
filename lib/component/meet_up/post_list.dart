import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lifefit/model/meetup_model.dart';
import 'applicant_list.dart';
import 'apply_button.dart';
import 'apply_sheet.dart';
import 'create_post.dart';

/// 게시글 리스트를 출력
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


    return ListView.builder(
      itemCount: sortedPosts.length + (widget.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < sortedPosts.length) {
          final post = sortedPosts[index]; // 현재 게시글

          return Card(
            shape: ContinuousRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
            margin: const EdgeInsets.symmetric(vertical: 5),
            color: Colors.white,
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // 제목
                          Text(
                            post.title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(width: 10),

                          Text(
                            '작성자: ${post.authorName}',
                            style: const TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                        ],
                      ),


                      const SizedBox(height: 5),
                      // 설명 표시
                      //Text(post.description),

                      // 위치 및 시간 표시
                      Row(
                        children: [
                          const Icon(Icons.place, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(post.location, style: const TextStyle(color: Colors.grey)),
                          const SizedBox(width: 16),
                          const Icon(Icons.access_time, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(post.dateTime, style: const TextStyle(color: Colors.grey)),
                        ],
                      ),

                      const SizedBox(height: 3),

                      //인원 수 신청 버튼
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          //정원 표시
                          Text(
                            '정원: ${post.currentPeople}명 / ${post.maxPeople}명',
                          ),

                          // 신청 버튼
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
                                    widget.onRefreshRequested?.call(); // 전체 리스트 새로고침
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

                // 상단 더보기 메뉴 (작성자만)
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
                            widget.onRefreshRequested?.call(); //Firestore 새로고침
                          }

                        } else if (value == 'delete') {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('삭제'),
                              content: const Text('해당 게시글을 삭제하시겠습니까?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(false), // 취소
                                  child: const Text('취소'),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.of(context).pop(true),  // 확인
                                  child: const Text('삭제'),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            await post.deleteFromFirestore(); //Firestore에서 삭제
                            widget.onRefreshRequested?.call(); //화면 새로고침
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
