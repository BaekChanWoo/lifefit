// feed_show.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lifefit/controller/feed_controller.dart';
import 'package:lifefit/component/community/feed_edit.dart';
import 'package:lifefit/controller/auth_controller.dart';
import 'dart:developer' as developer;
import 'package:timeago/timeago.dart' as timeago;


class FeedShow extends StatefulWidget {
  final int feedId;
  const FeedShow(this.feedId, {super.key});

  @override
  State<FeedShow> createState() => _FeedShowState();
}

class _FeedShowState extends State<FeedShow> {
  final FeedController feedController = Get.find<FeedController>();
  final AuthController authController = Get.find<AuthController>();

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('게시물 상세'),
        actions: [
          // 본인 게시물인 경우 수정/삭제 버튼 표시
          Obx(() {
            final feed = feedController.currentFeed.value;
            final isAuthor = feed != null && isCurrentUserAuthor();

            // 작성자 ID와 로그인한 사용자 ID가 일치할 때만 수정/삭제 버튼이 표시
            if (isAuthor) {
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
                          // HomeScreen으로 이동, Community 탭(인덱스 3) 활성화
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            Get.offAllNamed('/', arguments: {'selectedTab': 3});
                          });
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
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 이미지
              if (feed.imageId != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                    'http://10.0.2.2:3000${feed.imagePath}', // 실제 서버 URL
                    width: double.infinity,
                   // height: 250,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Image.asset(
                      'assets/img/mypageimg.jpg',
                      width: double.infinity,
                    //  height: 250,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              )
              else
                ClipRRect(
                  borderRadius: BorderRadius.circular(6.0),
                  child: Image.asset(
                    'assets/img/mypageimg.jpg',
                    width: double.infinity,
                    height: 250,
                    fit: BoxFit.cover,
                  ),
                ),
              const SizedBox(height: 16),
              // 사용자 프로필 정보 (사진과 이름)
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: feed.imagePath != null
                        ? NetworkImage('http://10.0.2.2:3000${feed.imagePath}')
                        : const AssetImage('assets/img/mypageimg.jpg') as ImageProvider,
                    onBackgroundImageError: feed.imagePath != null
                        ? (exception, stackTrace) {
                      developer.log('Profile image load failed: $exception', name: 'FeedShow');
                    }
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    feed.writer?.name ?? '익명',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(top: 10.0), // 위쪽 여백만 설정
                child: Divider(
                  color: Colors.grey[300],
                  thickness: 1.0,
                ),
              ),
              const SizedBox(height: 16),
              // 제목
              Text(
                feed.title,
                style:
                Theme.of(context).textTheme.headlineSmall
                //TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              // 카테고리 및 작성 시간
              Row(
                children: [
                  Text(feed.category),
                  const SizedBox(width: 8),
                  Text(
                    timeago.format(
                        feed.createdAt!
                    ), // 시간ago 패키지 활용 추천
                    //'${(DateTime.now().difference(feed.createdAt!).inMinutes)}분 전',
                    style: const TextStyle(color: Colors.grey, fontSize: 14
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // 별명
              Text(
                feed.name,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 32),
              // 설명
              Text(
                feed.content,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 24),
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
          ),
        );
      }),
    );
  }
}
