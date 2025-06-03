import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:lifefit/component/community/feed_create.dart';
import 'package:lifefit/controller/feed_controller.dart';
import 'package:lifefit/const/colors.dart';
import 'package:lifefit/component/community/main_mypage.dart';
import 'package:lifefit/component/community/feed.dart';
import 'package:lifefit/controller/home_controller.dart';
import 'package:lifefit/component/community/feed_search_form.dart';

// 커뮤니티 메인 페이지
class Community extends StatefulWidget {
  const Community({super.key});

  @override
  State<Community> createState() => _CommunityState();
}

class _CommunityState extends State<Community> with SingleTickerProviderStateMixin{
  final FeedController feedController = Get.put(FeedController());
  late TabController _tabController;
  bool _showFab = true;


  @override
  void initState(){
    super.initState();

    // Get.arguments에서 initialTab을 확인하여 초기 탭 설정
    int initialTab = Get.arguments != null && Get.arguments['initialTab'] != null
        ? Get.arguments['initialTab']
        : 0;

    _tabController = TabController(
        length: 2,
        vsync: this,
        initialIndex: initialTab, // 초기 탭 설정
    );


    _tabController.animation!.addListener((){
      final value = _tabController.animation!.value;
      final show = value < 0.5; // 0번 탭에 가까우면 보여주기(0.0 피드 , 1.0 마이페이지)

      if( show != _showFab) {
        setState(() { // 탭 전환시 상태 갱신
          _showFab = show;
        });
      }
    });
  }
  @override
  void dispose(){
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return  Scaffold(
        floatingActionButton: _showFab ? FloatingActionButton.extended(
          backgroundColor: PRIMARY_COLOR,
          onPressed: (){
            Get.to(() => const FeedCreate());
            },
          icon: Icon(Icons.add ,
            color: Colors.black,
          ),
          label: Text("글쓰기",
            style: TextStyle(fontSize: 15.0 , color: Colors.black),
          ),
        ) : null,
        appBar: AppBar(
          title: Row(
            children: [
            Obx(() =>  Text(
              Get.find<HomeScreenController>().userName.value,
              style: TextStyle(fontSize: 22 , fontWeight: FontWeight.w600),
            ),
            ),
          ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: IconButton(
                onPressed: (){
                  Get.to(() => const FeedSearchForm());
                },
                icon : const Icon(CupertinoIcons.search , size: 25,),
              ),
            ),
            /*
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Icon(Icons.favorite , size: 25,),
            ),
             */
          ],
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: PRIMARY_COLOR,
            indicatorWeight: 3.0,
            isScrollable: false,
            indicatorSize: TabBarIndicatorSize.tab,
              tabs: [
                Tab(text: "피드",),
                Tab(text: "마이페이지",),
              ]
          ),
        ),
        body: TabBarView(
            controller: _tabController,
            children: [
              Feed(),
              MainMyPage(),
            ],
        ),

    );
  }



}

