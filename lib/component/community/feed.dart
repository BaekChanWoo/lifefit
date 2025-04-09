import 'package:lifefit/component/community/feed_category_button.dart';
import 'package:flutter/material.dart';

// 피드 페이지
class Feed extends StatefulWidget {
  const Feed({super.key});

  @override
  State<Feed> createState() => _FeedState();
}

class _FeedState extends State<Feed> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          children: [
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: const [
                  CategoryButton(title: '요가',),
                  SizedBox(width: 12,),
                  CategoryButton(title: '헬스',),
                  SizedBox(width: 12,),
                  CategoryButton(title: '다이어트',),
                  SizedBox(width: 12,),
                  CategoryButton(title: '러닝',),
                  SizedBox(width: 12,),
                  CategoryButton(title: '필라테스',),
                  
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
