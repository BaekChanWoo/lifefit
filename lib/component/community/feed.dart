import 'package:lifefit/component/community/feed_category_button.dart';
import 'package:flutter/material.dart';
import 'package:lifefit/component/community/feed_list_item.dart';

// 피드 페이지
class Feed extends StatefulWidget {

  const Feed({super.key});

  @override
  State<Feed> createState() => _FeedState();
}

// 러닝, 헬스, 요가, 필라테스, 싸이클, 클라이밍, 농구
class _FeedState extends State<Feed> {
  List<Map<String , dynamic>> feedList = [
    { 'id': 1,
      'title': '러닝은 무조건 1시간',
      'content' : '러닝은 최소 1시간 이상해요 효과가 보입니다',
      'name' : '백찬우',
    },
    { 'id': 2,
      'title': '필라테스는 이렇게',
      'content' : '필라테스는 이렇게 해야 합니다',
      'name' : '차예빈',
    },
    { 'id': 3,
      'title': '농구 레이업',
      'content' : '이때 점프해야 잘 들어갑니다',
      'name' : '조성준',
    },
    { 'id': 4,
      'title': '헬스는 이렇게',
      'content' : '근력운동 전에는 유산소를 꼭 해야합니다.',
      'name' : '이예린',
    },
    { 'id': 5,
      'title': '필라테스는 열심히',
      'content' : '필라테스 전에는 몸풀기를 꼭 해야합니다.',
      'name' : '이예린',
    },
  ];

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
                  CategoryButton(title: '요가',),
                  SizedBox(width: 12,),
                  CategoryButton(title: '헬스',),
                  SizedBox(width: 12,),
                  CategoryButton(title: '클라이밍',),
                  SizedBox(width: 12,),
                  CategoryButton(title: '러닝',),
                  SizedBox(width: 12,),
                  CategoryButton(title: '싸이클',),
                  SizedBox(width: 12,),
                  CategoryButton(title: '필라테스',),
                  SizedBox(width: 12,),
                  CategoryButton(title: '농구',),
                ],
              ),
            ),
            const SizedBox(height: 10,),
            // 피드 리스트 목록
            Expanded(
                child: ListView.builder(
                  itemCount: feedList.length,
                  itemBuilder: (context , index){
                    final item = feedList[index];
                    return FeedListItem(item);
                  },
                )
            ),
          ],
        ),
      ),
    );
  }
}
