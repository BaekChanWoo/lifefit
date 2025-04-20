import 'package:flutter/material.dart';
import 'package:lifefit/component/community/mypage.dart';
import 'package:lifefit/const/colors.dart';
import 'package:lifefit/component/community/feed_create.dart';
import 'package:get/get.dart';
import 'package:lifefit/controller/feed_controller.dart';


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
        body: Obx(() {
          int postCount = feedController.feedList.length;
          return CustomScrollView( // 여러 Sliver 기반 위젯을 조합해 스크롤 UI 구현
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.only(top: 8.0), // 상단 여백 추가
              sliver: postCount > 0 ?
              SliverGrid( // 게시물이 있으면 3열 그리드 표시
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  //crossAxisSpacing: 1.0, // 열 사이의 간격 1.0픽셀
                  //mainAxisSpacing: 1.0, // 행 사이의 간격 1,0 픽셀
                ),
                delegate: SliverChildBuilderDelegate(
                      (context, index) =>
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                //color: PRIMARY_COLOR,
                                color: Colors.black,
                                width: 1.0,
                              ),
                            ),
                            child: Image.asset(
                              'assets/img/gridimg.jpg'
                              , fit: BoxFit.cover,
                            ),
                          ),
                  childCount: postCount,
                ),
              ) : SliverToBoxAdapter(
                // 게시물이 없으면 빈 상태 UI 표시
                // CustomScrollView 안에서 스크롤 가능한 리스트,그리드 외에 고정된 ui 요소를 추가하고 싶을 때 사용
                child: Center( // 일반 위젯(center)을 Sliver 처럼 동작하도록 감싸는 어댑터
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 80.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                      Image.asset(
                      'assets/img/empty_state.png', // 가정: 빈 상태 이미지
                      width: 120.0,
                      height: 120.0,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.image_not_supported, // 이미지 로드 실패 시 대체 아이콘
                        size: 120.0,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Text(
                      '아직 게시물이 없어요!\n지금 첫 게시물을 작성해보세요!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: () {
                        // 글쓰기 기능 구현 (예: 새로운 게시물 추가)
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
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: const Text(
                        '글쓰기',
                        style: TextStyle(fontSize: 16.0),
                      ),
                    ),
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