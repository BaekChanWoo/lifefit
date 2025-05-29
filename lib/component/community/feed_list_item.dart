import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lifefit/component/community/feed_show.dart';
import 'package:lifefit/model/feed_model.dart';
import 'package:lifefit/controller/feed_controller.dart';



const double _imageSize = 100;

// 피드(게시물) 리스트 아이템
class FeedListItem extends StatefulWidget {
  final FeedModel data;
  const FeedListItem(this.data, {super.key});

  @override
  State<FeedListItem> createState() => _FeedListItemState();
}

class _FeedListItemState extends State<FeedListItem> {
  @override
  Widget build(BuildContext context) {
    final FeedController feedController = Get.find<FeedController>();

    return InkWell(
      onTap: () {
        // 상세 페이지로 이동
        Get.to(() => FeedShow(widget.data.id));
      },
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Stack(
          children: [
            // ───────────────────────────────────────────────────
            // 기존 UI: 이미지 + 텍스트 부분
            // ───────────────────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // (1) 이미지
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: widget.data.imageId != null && widget.data.imagePath != null
                      ? Image.network(
                    'http://10.0.2.2:3000${widget.data.imagePath}',
                    width: _imageSize,
                    height: _imageSize,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Image.asset(
                      'assets/img/mypageimg.jpg',
                      width: _imageSize,
                      height: _imageSize,
                      fit: BoxFit.cover,
                    ),
                  )
                      : Image.asset(
                    'assets/img/mypageimg.jpg',
                    width: _imageSize,
                    height: _imageSize,
                    fit: BoxFit.cover,
                  ),
                ),

                // (2) 텍스트 정보
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 11),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 제목
                        Text(
                          widget.data.title,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        // 카테고리 + 작성 시간
                        Row(
                          children: [
                            Text(
                              widget.data.category,
                              style: const TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              widget.data.createdAt != null
                                  ? '${DateTime.now().difference(widget.data.createdAt!).inMinutes}분전'
                                  : '알 수 없음',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        // 작성자 이름
                        Text(
                          widget.data.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // (3) 더보기 버튼
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.more_vert,
                    color: Colors.grey,
                    size: 16,
                  ),
                ),
              ],
            ),

            // ───────────────────────────────────────────────────
            // (4) 댓글 수 · 좋아요 수 부분 (항상 최신값을 Obx로 읽어옴)
            // ───────────────────────────────────────────────────
            Positioned(
              right: 10,
              bottom: 0,
              child: Obx(() {
                // 컨트롤러의 feedList에서 id 일치 아이템을 찾고,
                // 없으면 widget.data(초기값)를 그대로 사용
                final displayFeed = feedController.feedList.firstWhere(
                      (f) => f.id == widget.data.id,
                  orElse: () => widget.data,
                );

                return Row(
                  children: [
                    // 댓글 아이콘 + 동적 개수
                    const Icon(Icons.mode_comment_outlined, color: Colors.grey, size: 16),
                    const SizedBox(width: 2),
                    Text(
                      '${displayFeed.comments.length}',
                      style: const TextStyle(fontSize: 14),
                    ),

                    const SizedBox(width: 12),

                    // 좋아요 아이콘 + 동적 개수
                    Icon(
                      displayFeed.likedByMe ? Icons.favorite : Icons.favorite_border,
                      color: displayFeed.likedByMe ? Colors.red : Colors.grey,
                      size: 16,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '${displayFeed.likeCount}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}