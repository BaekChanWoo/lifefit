import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lifefit/controller/feed_controller.dart';
import 'package:lifefit/component/community/feed_list_item.dart';

class FeedSearchResult extends StatefulWidget {
  final String keyword;
  const FeedSearchResult(this.keyword, {super.key});

  @override
  State<FeedSearchResult> createState() => _FeedSearchResultState();
}

class _FeedSearchResultState extends State<FeedSearchResult> {
  final FeedController feedController = Get.put(FeedController());
  int _currentPage = 1;

  @override
  void initState(){
    super.initState();
    feedController.searchIndex(widget.keyword);
  }

  Future<void> _onRefresh() async{
    _currentPage = 1;
    await feedController.searchIndex(widget.keyword);
  }

  bool _onNotification(ScrollNotification scrollInfo){
    if(scrollInfo is ScrollEndNotification &&
        scrollInfo.metrics.extentAfter == 0){
      feedController.searchIndex(widget.keyword , page:  ++_currentPage);
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(widget.keyword),
      ),
      body: Column(
        children: [
          Expanded(
              child: Obx((){
                if(feedController.searchList.isEmpty){
                  return Center(
                    child: Text(
                      '결과가 없습니다.',
                      style: TextStyle(fontSize: 16 , color: Colors.grey),
                    ),
                  );
                } else {
                  return NotificationListener<ScrollNotification>(
                      onNotification: _onNotification,
                      child: RefreshIndicator(
                          onRefresh: _onRefresh,
                          child: ListView.builder(
                              itemCount: feedController.searchList.length,
                              itemBuilder: (context , index) {
                                return FeedListItem(feedController.searchList[index]);
                              },
                          ),
                          )
                  );
                }
              })
          )
        ],
      ),
    );
  }
}
