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
      // 전체 배경색을 부드러운 회색으로 설정
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0, // 그림자 제거로 깔끔한 느낌
        surfaceTintColor: Colors.transparent, // Material 3
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text('게시물', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
        actions: [
          Obx(() {
            final feed = feedController.currentFeed.value;
            if (feed == null) return const SizedBox.shrink();

            final isAuthor = feed.writer?.id == authController.currentUserId;
            if (isAuthor) {
              return Row(
                children: [
                  // 수정 버튼
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: Colors.black54),
                    onPressed: () => Get.to(() => FeedEdit(feed)),
                  ),
                  // 🗑삭제 버튼
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.black54),
                    onPressed: () async {
                      // 삭제 확인 다이얼로그 - 더 깔끔한 디자인
                      final confirm = await Get.dialog<bool>(
                        AlertDialog(
                          title: const Text('게시물 삭제'),
                          content: const Text('정말로 이 게시물을 삭제하시겠습니까?'),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          backgroundColor: Colors.white,
                          actions: [
                            // 취소 버튼 - 회색 텍스트
                            TextButton(
                              onPressed: () => Get.back(result: false),
                              child: Text('취소', style: TextStyle(color: Colors.black)),
                            ),
                            // 삭제 버튼 - 빨간 텍스트로 강조
                            TextButton(
                              onPressed: () => Get.back(result: true),
                              child: const Text('삭제', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        final success = await feedController.feedDelete(widget.feedId);
                        if (success) {
                          Get.offAllNamed('/', arguments: {'selectedTab': 3});
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
          // 로딩 인디케이터 - 브랜드 컬러 적용
          return const Center(child: CircularProgressIndicator(color: PRIMARY_COLOR));
        }

        return Column(
          children: [
            //  메인 컨텐츠 영역 (게시물 + 댓글) - 스크롤 가능한 영역
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  color: Colors.white, // 메인 컨텐츠는 흰색 배경
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 게시물 영역
                      // 1) 작성자 정보 섹션
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            // 프로필 이미지
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: Colors.grey[200], // 로딩 시 배경색
                              backgroundImage: feed.imagePath != null
                                  ? const AssetImage('assets/img/mypageimg.jpg') as ImageProvider
                              // NetworkImage('http://10.0.2.2:3000/${feed.imagePath}')
                                  : NetworkImage('http://10.0.2.2:3000/${feed.imagePath}')
                              // const AssetImage('assets/img/mypageimg.jpg') as ImageProvider,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  //  작성자 이름 - 더 굵고 진한 색상
                                  Text(
                                    feed.writer?.name ?? '익명',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      // 🏷 카테고리 태그
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: PRIMARY_COLOR.withOpacity(0.1), // 메인 컬러
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          feed.category,
                                          style: const TextStyle(
                                            color: PRIMARY_COLOR,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      //  작성 시간
                                      Text(
                                        timeago.format(feed.createdAt!),
                                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 2) 제목 섹션
                      if (feed.title.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                          child: Text(
                            feed.title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                              height: 1.3, // 줄간격
                            ),
                          ),
                        ),

                      // 3) 본문 내용 - 가독성 개선
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Text(
                          feed.content,
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.5, // 줄간격
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.justify,
                        ),
                      ),

                      // 4) 이미지 섹션 - 둥근 모서리와 에러 처리 개선
                      if (feed.imageId != null)
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12), // 둥근 모서리 추가
                            child: AspectRatio(
                              aspectRatio: 16 / 9,
                              child: Image.network(
                                'http://10.0.2.2:3000/${feed.imagePath}',
                                fit: BoxFit.cover,
                                width: double.infinity,
                                // 에러 처리  - 기본 이미지 대신 에러 아이콘
                                errorBuilder: (_, __, ___) => Container(
                                  color: Colors.grey[200],
                                  child: const Center(
                                    child: Icon(Icons.image_not_supported,
                                        color: Colors.grey, size: 40),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                      // 5) 좋아요·댓글 액션 바
                      Container(
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            // 좋아요 버튼 - 터치하기 쉽게 InkWell로 감싸기
                            Obx(() => InkWell(
                              onTap: feedController.toggleLike,
                              borderRadius: BorderRadius.circular(20),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                child: Row(
                                  children: [
                                    Icon(
                                      feedController.isLiked.value
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: feedController.isLiked.value
                                          ? Colors.red
                                          : Colors.grey[600],
                                      size: 22,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${feedController.likeCount.value}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: feedController.isLiked.value
                                            ? Colors.red
                                            : Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )),
                            const SizedBox(width: 16),
                            // 댓글 수 표시
                            Row(
                              children: [
                                Icon(Icons.chat_bubble_outline,
                                    size: 20, color: Colors.grey[600]),
                                const SizedBox(width: 6),
                                Text(
                                  '${feedController.comments.length}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // 구분선 - 게시물과 댓글 사이 ═══
                      Container(
                        height: 8,
                        color: Colors.grey[50], // 부드러운 구분
                      ),

                      //  댓글 영역
                      Container(
                        color: Colors.white,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 댓글 헤더 - 제목과 개수 배지
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                              child: Row(
                                children: [
                                  const Text(
                                    '댓글',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // 댓글 개수 배지
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${feedController.comments.length}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // 댓글 목록 또는 빈 상태
                            if (feedController.comments.isEmpty)
                            // 빈 댓글 상태 - 친근한 메시지와 아이콘
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 40),
                                child: Center(
                                  child: Column(
                                    children: [
                                      Icon(Icons.chat_bubble_outline,
                                          size: 48, color: Colors.grey[300]),
                                      const SizedBox(height: 12),
                                      Text(
                                        '아직 댓글이 없어요\n첫 댓글을 남겨보세요!',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.grey[500],
                                          fontSize: 14,
                                          height: 1.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else
                            // 댓글 목록 - 메신저 스타일 말풍선
                              ...feedController.comments.map((comment) {
                                return Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // 댓글 작성자 아바타
                                      CircleAvatar(
                                        radius: 16,
                                        backgroundColor: Colors.grey[200],
                                        backgroundImage: const AssetImage('assets/img/mypageimg.jpg'),
                                      ),
                                      const SizedBox(width: 12),
                                      // 댓글 말풍선
                                      Expanded(
                                        child: Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[50], // 부드러운 배경색
                                            borderRadius: BorderRadius.circular(16), // 둥근 말풍선
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              // 댓글 작성자 이름
                                              Text(
                                                comment.userName,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 13,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              // 댓글 내용
                                              Text(
                                                comment.content,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  height: 1.4, // 줄간격
                                                  color: Colors.black87,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),

                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // 댓글 입력창 (하단 고정)
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Colors.grey[200]!, width: 1),
                ),
              ),
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 12,
                bottom: MediaQuery.of(context).viewInsets.bottom + 12,
              ),
              child: Row(
                children: [
                  Obx(() {
                    final avatarUrl = authController.profileImage.value;
                    return CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: avatarUrl != null
                          ? NetworkImage(avatarUrl)
                          : const AssetImage('assets/img/mypageimg.jpg') as ImageProvider,
                    );
                  }),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: TextField(
                        controller: _commentController,
                        decoration: const InputDecoration(
                          hintText: '댓글을 입력하세요...',
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: const BoxDecoration(
                      color: PRIMARY_COLOR,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send_rounded,
                          size: 18, color: Colors.white),
                      onPressed: () {
                        final text = _commentController.text.trim();
                        if (text.isNotEmpty) {
                          feedController.postComment(text);
                          _commentController.clear();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}





