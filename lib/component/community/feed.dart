import 'package:lifefit/controller/feed_controller.dart';
import 'package:lifefit/component/community/feed_category_button.dart';
import 'package:flutter/material.dart';
import 'package:lifefit/component/community/feed_list_item.dart';
import 'package:get/get.dart';


// 피드 페이지
class Feed extends StatefulWidget {

  const Feed({super.key});

  @override
  State<Feed> createState() => _FeedState();
}

// 러닝, 헬스, 요가, 필라테스, 싸이클, 클라이밍, 농구
class _FeedState extends State<Feed> {
  int _currentPage = 1;
  final FeedController feedController = Get.put(FeedController()); // 인스턴스 생성

  @override
  void initState(){
    super.initState();
    //feedController.feedIndex(_currentPage);
  }
  bool _onNotification(ScrollNotification scrollInfo) {
    if (scrollInfo is ScrollEndNotification &&
        scrollInfo.metrics.extentAfter == 0) {
      //feedController.feedIndex(page: ++_currentPage);
      return true;
    }
    return false;
  }

  Future<void> _onRefresh() async {
    _currentPage = 1;
    //await feedController.feedIndex();
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
                children: const [
                  CategoryButton(icon:Icons.self_improvement , title: '요가',),
                  SizedBox(width: 12,),
                  CategoryButton(icon:Icons.fitness_center, title: '헬스',),
                  SizedBox(width: 12,),
                  CategoryButton(icon:Icons.terrain , title: '클라이밍',),
                  SizedBox(width: 12,),
                  CategoryButton(icon:Icons.directions_run, title: '러닝',),
                  SizedBox(width: 12,),
                  CategoryButton(icon:Icons.directions_bike , title: '싸이클',),
                  SizedBox(width: 12,),
                  CategoryButton(icon:Icons.accessibility_new , title: '필라테스',),
                  SizedBox(width: 12,),
                  CategoryButton(icon:Icons.sports_basketball , title: '농구',),
                ],
              ),
            ),
            const SizedBox(height: 10,),
            // 피드 리스트 목록
            // feedList가 변경될 때마다 관련 위젯이 자동으로 업데이트
            Expanded(
              child: Obx(() => NotificationListener<ScrollNotification>(
                      onNotification: _onNotification,
                      child: RefreshIndicator(
                        onRefresh: _onRefresh,
                        child: ListView.builder(
                          itemCount: feedController.feedList.length,
                          itemBuilder: (context, index) {
                            final item = feedController.feedList[index];
                          return FeedListItem(item);
                           },
                        ),
                       ),
               ),
              ),
             )
            ],
        ),
      ),
    );
  }
}