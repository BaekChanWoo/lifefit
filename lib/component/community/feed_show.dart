// feed_show.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lifefit/controller/feed_controller.dart';
import 'package:lifefit/component/community/feed_edit.dart';
import 'package:lifefit/controller/auth_controller.dart';
import 'dart:developer' as developer;
import 'package:timeago/timeago.dart' as timeago;
import 'package:lifefit/const/colors.dart';


class FeedShow extends StatefulWidget {
  final int feedId;
  const FeedShow(this.feedId, {super.key});

  @override
  State<FeedShow> createState() => _FeedShowState();
}

class _FeedShowState extends State<FeedShow> {
  final FeedController feedController = Get.find<FeedController>();
  final AuthController authController = Get.find<AuthController>();
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    feedController.feedShow(widget.feedId);
  }

  // 현재 사용자가 게시물 작성자인지 확인
  bool isCurrentUserAuthor() {
    final feed = feedController.currentFeed.value;
    if (feed == null) return false;

    try {
      // 디버깅 로그 추가
      developer.log(
          'isCurrentUserAuthor check - isMe: ${feed.isMe}, '
              'writerId: ${feed.writer?.id}, '
              'currentUserId: ${authController.currentUserId}',
          name: 'FeedShow'
      );

      // 로그인한 사용자 ID와 피드 작성자 ID 직접 비교
      int currentUserId = authController.currentUserId; // 현재 로그인한 사용자 ID
      // 작성자 ID가 있고 현재 로그인한 사용자 ID와 일치할 경우에만 true 반환
      return feed.writer != null && feed.writer!.id == currentUserId;
    } catch (e) {
      developer.log('Error in isCurrentUserAuthor: $e', name: 'FeedShow');
      return false;
    }
  }

  @override
  void dispose(){
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text('게시물 상세', style: TextStyle(color: Colors.black)),
        actions: [
          Obx(() {
            final feed = feedController.currentFeed.value;
            final isAuthor = feed != null && feed.writer?.id == authController.currentUserId;
            if (isAuthor) {
              return Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.black87),
                    onPressed: () => Get.to(() => FeedEdit(feed!)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.black87),
                    onPressed: () async {
                      final confirm = await Get.dialog(
                        AlertDialog(
                          title: const Text('삭제 확인'),
                          content: const Text('정말로 이 게시물을 삭제하시겠습니까?'),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: Colors.white,
                          actions: [
                            ElevatedButton(
                                onPressed: () => Get.back(result: false),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: PRIMARY_COLOR,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
                              ),
                                child: const Text('취소'),
                            ),
                            ElevatedButton(
                                onPressed: () => Get.back(result: true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: PRIMARY_COLOR,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
                                ),
                                child: const Text('삭제'),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        final success = await feedController.feedDelete(widget.feedId);
                        if (success) Get.offAllNamed('/', arguments: {'selectedTab': 3});
                      }
                    },
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      body: Obx(() {
        final feed = feedController.currentFeed.value;
        if (feed == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
// Post Card
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
// Header
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundImage: feed.imagePath != null
                                ? NetworkImage('http://10.0.2.2${feed.imagePath}')
                                : const AssetImage('assets/img/mypageimg.jpg') as ImageProvider,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(feed.writer?.name ?? '익명', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(feed.category, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                    const SizedBox(width: 8),
                                    Text(timeago.format(feed.createdAt!), style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
// Image
                    if (feed.imageId != null)
                      ClipRRect(
                        borderRadius: BorderRadius.zero,
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Image.network(
                            'http://10.0.2.2${feed.imagePath}',
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (_, __, ___) => Image.asset('assets/img/mypageimg.jpg', fit: BoxFit.cover),
                          ),
                        ),
                      )
                    else
                      ClipRRect(
                        borderRadius: BorderRadius.zero,
                        child: Image.asset('assets/img/mypageimg.jpg', width: double.infinity, height: 250, fit: BoxFit.cover),
                      ),
// Title & Content
                    if (feed.title.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                        child: Text(feed.title, style: Theme.of(context).textTheme.titleLarge),
                      ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                      child: Text(feed.content, style: const TextStyle(fontSize: 16), textAlign: TextAlign.justify),
                    ),
// Actions
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          Obx(() => IconButton(
                            icon: Icon(
                              feedController.isLiked.value ? Icons.favorite : Icons.favorite_border,
                              color: feedController.isLiked.value ? Colors.red : Colors.black,
                            ),
                            onPressed: feedController.toggleLike,
                          )),
                          Obx(() => Text('${feedController.likeCount.value}', style: const TextStyle(fontWeight: FontWeight.w600))),
                          const SizedBox(width: 24),
                          const Icon(Icons.mode_comment_outlined, size: 24),
                          const SizedBox(width: 8),
                          Text('${feed.comments.length}', style: const TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Divider(),  // 포스트와 댓글 구분선
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text('댓글', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              Obx(() => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: feedController.comments
                    .map((c) => ListTile(
                  dense: true,
                  horizontalTitleGap: 0,
                  minVerticalPadding: 4,
                  title: Text(c.userName, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(c.content),
                  contentPadding: EdgeInsets.zero,
                ))
                    .toList(),
              )),
// Comment Input UI 개선
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                ),
                child: Row(
                  children: [
                    Obx(() {
                      final avatarUrl = authController.profileImage.value;
                      return CircleAvatar(
                        radius: 16,
                        backgroundImage: avatarUrl != null
                            ? NetworkImage(avatarUrl)
                            : const AssetImage('assets/img/mypageimg.jpg') as ImageProvider,
                      );
                    }),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        decoration: const InputDecoration(
                          hintText: '댓글 달기...',
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send, size: 20, color: Colors.grey[600]),
                      onPressed: () {
                        final text = _commentController.text.trim();
                        if (text.isNotEmpty) {
                          feedController.postComment(text);
                          _commentController.clear();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}






