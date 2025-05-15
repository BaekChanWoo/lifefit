import 'package:lifefit/controller/feed_controller.dart';
import 'package:lifefit/component/community/feed_category_button.dart';
import 'package:flutter/material.dart';
import 'package:lifefit/component/community/feed_list_item.dart';
import 'package:get/get.dart';
import 'package:lifefit/const/categories.dart';


// 피드 페이지(index.dart)
class Feed extends StatefulWidget {

  const Feed({super.key});

  @override
  State<Feed> createState() => _FeedState();
}

// 러닝, 헬스, 요가, 필라테스, 싸이클, 클라이밍, 농구
class _FeedState extends State<Feed> {
  final FeedController feedController = Get.put(FeedController()); // 인스턴스 생성

  @override
  void initState() {
    super.initState();
    _loadFeed(); // 비동기 메서드로 분리
  }

  Future<void> _loadFeed() async {
    await feedController.feedIndex(
        page: 1,
        category: feedController.selectedCategory.value.isEmpty
            ? null : feedController.selectedCategory.value
    );
  }

  bool _onNotification(ScrollNotification scrollInfo) {
    if (scrollInfo is ScrollEndNotification && scrollInfo.metrics.extentAfter == 0) {
      feedController.feedIndex(
        page: (feedController.feedList.length ~/ 10) + 1,
        category: feedController.selectedCategory.value.isEmpty ? null : feedController.selectedCategory.value,
      );
      return true;
    }
    return false;
  }

  Future<void> _onRefresh() async {
    await feedController.feedIndex(
      page: 1,
      category: feedController.selectedCategory.value.isEmpty ? null : feedController.selectedCategory.value,
    );
  }

  // 카테고리별 아이콘 매핑 함수
  IconData _getIconForCategory(String category) {
    switch (category) {
      case '요가':
        return Icons.self_improvement;
      case '헬스':
        return Icons.fitness_center;
      case '클라이밍':
        return Icons.terrain;
      case '러닝':
        return Icons.directions_run;
      case '싸이클':
        return Icons.directions_bike;
      case '필라테스':
        return Icons.accessibility_new;
      case '농구':
        return Icons.sports_basketball;
      default:
        return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          children: [
            SizedBox(
              height: 40,
              // 카테고리 바
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  CategoryButton(
                    icon: Icons.all_inclusive,
                    title: '전체',
                    isSelected: feedController.selectedCategory,
                    onTap: () {
                      feedController.selectedCategory.value = '';
                      feedController.feedIndex(page: 1);
                    },
                  ),
                  const SizedBox(width: 12),
                  ...feedCategories.map((category) => Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: CategoryButton(
                      icon: _getIconForCategory(category),
                      title: category,
                      isSelected: feedController.selectedCategory,
                      onTap: () {
                        feedController.selectedCategory.value = category;
                        feedController.feedIndex(page: 1, category: category);
                      },
                    ),
                  )).toList(),
                ],
              ),
            ),
            const SizedBox(height: 10,),
            // 피드 리스트 목록
            // feedList가 변경될 때마다 관련 위젯이 자동으로 업데이트
            Expanded(
              child: NotificationListener<ScrollNotification>(
                onNotification: _onNotification,
                child: RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: Obx(() {
                    if (feedController.isLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (feedController.feedList.isEmpty) {
                      return const Center(child: Text('피드가 없습니다.'));
                    }
                    return ListView.builder(
                      itemCount: feedController.feedList.length,
                      itemBuilder: (context, index) {
                        final item = feedController.feedList[index];
                        return FeedListItem(item);
                      },
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}