import 'package:flutter/material.dart';
import 'package:lifefit/component/yrin_music/music_top.dart';
import 'package:lifefit/component/yrin_music/change_category.dart';
import '';

void main() {
  runApp(const Music());
}

class Music extends StatefulWidget {
  const  Music({super.key});

  @override
  State <Music> createState() => _MusicState();
}

class _MusicState extends State< Music> {
  String? selectedCategory;
  final List<String> categories =
  ['요가', '클라이밍', '사이클', '농구', '러닝', '헬스', '필라테스' ];

  void onCategoryTap(String category) {
    setState(() {
      selectedCategory = category;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Stack(
          children: [
            MusicTop(),
            Positioned(
              top: 50,
              left: 10,
              child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 255,
                  child: ChangeCategory(
                      categories: categories,
                      onCategoryTap: onCategoryTap,
                      selectedCategory: selectedCategory
                  )
              ),
            ),
            Positioned(
              top: 305, // ChangeCategory의 높이 + top 값
              left: 10,
              right: 10,
              bottom: 10, // 원하는 bottom값
              child: selectedCategory == null
                  ? Center(
                child: Image.asset(
                  'assets/img/musicno.png',
                  width: 200,
                  height: 200,
                  fit: BoxFit.contain,
                ),
              )
                  : CategoryImages(selectedCategory: selectedCategory),
            ),
          ],
        ),
      ),

    );
  }
}



