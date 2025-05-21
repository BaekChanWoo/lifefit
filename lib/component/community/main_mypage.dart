import 'package:flutter/material.dart';
import 'package:lifefit/component/community/mypage.dart';
import 'package:lifefit/const/colors.dart';
import 'package:lifefit/component/community/feed_create.dart';
import 'package:get/get.dart';
import 'package:lifefit/controller/feed_controller.dart';
import 'package:lifefit/controller/auth_controller.dart';
import 'package:lifefit/model/feed_model.dart';
import 'package:lifefit/component/community/feed_show.dart';
import 'dart:developer' as developer;

// 마이페이지
class MainMyPage extends StatefulWidget {
  const MainMyPage({super.key});

  @override
  State<MainMyPage> createState() => _MainMyPageState();
}
// Sliver는 스크롤 가능한 영역의 부분을 나타냄
// SliverList = 스크롤 가능한 리스트
class _MainMyPageState extends State<MainMyPage> {
  final FeedController feedController = Get.put(FeedController());
  final AuthController authController = Get.find<AuthController>();


  @override
  void initState() {
    super.initState();
    // 이 페이지가 로드될 때, 모든 카테고리의 게시물을 가져오도록 feedIndex 호출
    // WidgetsBinding.instance.addPostFrameCallback을 사용하여 build가 완료된 후 안전하게 호출합니다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // category를 null로 전달하여 모든 카테고리의 게시물을 요청합니다.
      // page: 1은 첫 페이지의 데이터를 가져옴을 의미합니다.
      // 만약 사용자의 모든 게시물을 한 번에 가져와야 하고 서버가 이를 지원한다면,
      // 페이지네이션 없이 모든 데이터를 가져오는 별도의 메소드나 파라미터가 필요할 수 있습니다.
      // 현재는 feedIndex를 활용하여 첫 페이지의 전체 게시물을 가져옵니다.
      feedController.feedIndex(page: 1, category: null).then((_) {
        // 데이터 로드가 완료된 후 UI가 올바르게 업데이트되도록 setState를 호출할 수 있으나,
        // GetX의 Obx가 feedList의 변경을 감지하므로 명시적인 setState는 필요 없을 수 있습니다.
        if (mounted) {
          setState(() {}); // Obx가 반응하도록 강제 업데이트 (필요에 따라 사용)
        }
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      child: NestedScrollView( // 헤더와 바디의 스크롤을 조율
        headerSliverBuilder: (context , innerBoxIsScrolled){
          return [
            SliverList( // 스크롤 가능한 리스트로 마이페이지 위젯 배치
                delegate: SliverChildListDelegate.fixed([
                  MyPage() ,
                ]),
            ),
          ];
        },
        // feedController.feedList를 관찰하여 UI 갱신
        // Obx 위젯을 사용하여 feedController.feedList 및 feedController.isLoading 상태 변화 감지
        body: Obx(() {
          // 데이터 로딩 중 UI
          if (feedController.isLoading.value && feedController.feedList.isEmpty) {
            // feedList가 비어있고 로딩중일때만 전체 화면 로딩 표시
            return const Center(child: CircularProgressIndicator());
          }

          int? currentUserId;
          try {
            currentUserId = authController.currentUserId;
          } catch (e) {
            developer.log('Error getting current user ID: $e', name: 'MainMyPage');
            currentUserId = null;
          }

          // 현재 사용자의 게시물만 필터링
          // feedController.feedList가 모든 카테고리 게시물을 포함하고 있다고 가정
          final List<FeedModel> myFeeds = currentUserId == null
              ? []
              : feedController.feedList.where((feed) {
            return feed.writer?.id == currentUserId;
          }).toList();

          developer.log(
              'Current User ID: $currentUserId, Total Feeds in Controller: ${feedController.feedList.length}, MyFeeds on MyPage: ${myFeeds.length}',
              name: 'MainMyPage');
          if (feedController.feedList.isNotEmpty && myFeeds.isEmpty && currentUserId != null) {
            developer.log('No posts found for user $currentUserId even though feedList is not empty. Check writer IDs.', name: 'MainMyPage');
            feedController.feedList.forEach((feed) {
              developer.log('Feed ID: ${feed.id}, Writer ID: ${feed.writer?.id}', name: 'MainMyPageFeedCheck');
            });
          }
          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.only(top: 8.0),
                sliver: myFeeds.isNotEmpty
                    ? SliverGrid(
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 1.0,
                    mainAxisSpacing: 1.0,
                  ),
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final feed = myFeeds[index];
                      return GestureDetector(
                        onTap: () {
                          Get.to(() => FeedShow(feed.id));
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.black,
                              width: 0.5, // 테두리 두께 약간 줄임
                            ),
                          ),
                          child: feed.imagePath != null && feed.imagePath!.isNotEmpty
                              ? Image.network(
                            'http://10.0.2.2:3000${feed.imagePath}', // 실제 서버 URL 및 이미지 경로
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              developer.log('Error loading image: ${feed.imagePath}, Error: $error', name: 'MainMyPage');
                              return Image.asset(
                                'assets/img/gridimg.jpg', // 에러 시 기본 이미지
                                fit: BoxFit.cover,
                              );
                            },
                            loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                          )
                              : Image.asset(
                            'assets/img/gridimg.jpg', // 이미지 없을 시 기본 이미지
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                    childCount: myFeeds.length,
                  ),
                )
                    : SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding:
                      const EdgeInsets.symmetric(vertical: 80.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 로딩 중이 아닐 때만 "게시물 없음" UI 표시
                          if (!feedController.isLoading.value) ...[
                            Image.asset(
                              'assets/img/empty_state.png',
                              width: 120.0,
                              height: 120.0,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (context, error, stackTrace) =>
                              const Icon(
                                Icons.image_not_supported,
                                size: 120.0,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 16.0),
                            Text(
                              '아직 작성한 게시물이 없어요!\n지금 첫 게시물을 작성해보세요!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16.0,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 16.0),
                            ElevatedButton(
                              onPressed: () {
                                Get.to(() => const FeedCreate());
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: PRIMARY_COLOR,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 30.0,
                                  vertical: 15.0,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(8.0),
                                ),
                              ),
                              child: const Text(
                                '글쓰기',
                                style: TextStyle(fontSize: 16.0),
                              ),
                            ),
                          ] else ...[
                            // feedList는 비어있지만 아직 로딩 중일 수 있음 (initState 호출 직후)
                            const CircularProgressIndicator(),
                            const SizedBox(height: 16.0),
                            const Text("게시물을 불러오는 중..."),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

}