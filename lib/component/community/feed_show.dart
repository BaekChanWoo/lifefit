// feed_show.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lifefit/const/colors.dart';
import 'package:lifefit/controller/feed_controller.dart';
import 'package:lifefit/component/community/feed_edit.dart';
import 'package:intl/intl.dart';
import 'package:lifefit/screen/community.dart';

class FeedShow extends StatefulWidget {
  final int feedId;
  const FeedShow(this.feedId, {super.key});

  @override
  State<FeedShow> createState() => _FeedShowState();
}

class _FeedShowState extends State<FeedShow> {
  final FeedController feedController = Get.find<FeedController>();

  @override
  void initState() {
    super.initState();
    feedController.feedShow(widget.feedId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('게시물 상세'),
        actions: [
          // 본인 게시물인 경우 수정/삭제 버튼 표시
          Obx(() {
            final feed = feedController.currentFeed.value;
            if (feed != null && feed.isMe) {
              return Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      Get.to(() => FeedEdit(feed));
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      final confirm = await Get.dialog<bool>(
                        AlertDialog(
                          title: const Text('삭제 확인'),
                          content: const Text('정말로 이 게시물을 삭제하시겠습니까?'),
                          actions: [
                            TextButton(
                              onPressed: () => Get.back(result: false),
                              child: const Text('취소'),
                            ),
                            TextButton(
                              onPressed: () => Get.back(result: true),
                              child: const Text('삭제'),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        final success = await feedController.feedDelete(widget.feedId);
                        if (success) {
                          //Get.back(); // 삭제 후 이전 화면으로 돌아감
                          // Community 페이지로 이동하며 Feed 탭(0번 인덱스) 선택
                          Get.offAll(() => const Community(), arguments: {'initialTab': 0});
                        }
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
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 이미지
              if (feed.imageId != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Image.network(
                    'https://your-server.com/images/${feed.imageId}', // 실제 서버 URL로 교체
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Image.asset(
                      'assets/img/mypageimg.jpg',
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              else
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Image.asset(
                    'assets/img/mypageimg.jpg',
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              const SizedBox(height: 16),
              // 제목
              Text(
                feed.title,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              // 카테고리 및 작성 시간
              Row(
                children: [
                  Text(
                    feed.category,
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${(DateTime.now().difference(feed.createdAt!).inMinutes)}분 전',
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // 별명
              Text(
                feed.name,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              // 설명
              Text(
                feed.content,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              // 좋아요 및 댓글 (더미 데이터)
              Row(
                children: [
                  const Icon(Icons.favorite_border, color: Colors.grey, size: 20),
                  const SizedBox(width: 4),
                  const Text('1', style: TextStyle(color: Colors.grey)),
                  const SizedBox(width: 16),
                  const Icon(Icons.message_outlined, color: Colors.grey, size: 20),
                  const SizedBox(width: 4),
                  const Text('1', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }
}
