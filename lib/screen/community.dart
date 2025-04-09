import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:lifefit/const/colors.dart';
import 'package:lifefit/component/community/main_mypage.dart';
import 'package:lifefit/component/community/feed.dart';

class Community extends StatefulWidget {
  const Community({super.key});

  @override
  State<Community> createState() => _CommunityState();
}

class _CommunityState extends State<Community> {
  @override
  Widget build(BuildContext context) {

    return DefaultTabController(
      initialIndex: 0,
      length: 2, // 탭 개수
      child: Scaffold(
        appBar: AppBar(
          title: Row(children: [
            const Text(
              '백찬우',
              style: TextStyle(fontSize: 25 , fontWeight: FontWeight.w500),
            ),
            Icon(Icons.keyboard_arrow_down, size: 25,),
          ],
          ),
          actions: [
            Padding(padding: const EdgeInsets.all(14.0),
              child: Icon(CupertinoIcons.search , size: 25,),
            ),
            Padding(padding: const EdgeInsets.all(14.0),
              child: Icon(Icons.favorite , size: 25,),
            ),
          ],
          bottom: TabBar(
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
            children: [
              Feed(),
              MainMyPage(),
            ],
        ),
      ),
    );
  }

}

