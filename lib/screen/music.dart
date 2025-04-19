import 'package:flutter/material.dart';
import 'package:lifefit/component/yrin_music/music_top.dart';
import 'package:lifefit/component/yrin_music/category_images.dart';
import 'package:lifefit/component/yrin_music/change_category.dart';

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
     home:  Scaffold(
      body: Stack(
        children: [
          MusicTop(),
          Positioned(
            top: 160,
            left: 10,
            right: 10,
            child: ChangeCategory( // CategorySelector 위젯 추가
              categories: categories,
              onCategoryTap: onCategoryTap,
              selectedCategory: selectedCategory,
            ),
          ),

          Positioned(
            top: 210, //assets/img/musicno.png 배치
            left: 20,
            right: 20,
            bottom: 10,
            child: selectedCategory == null
                ? Center(
              child: Transform.translate(
                offset: const Offset(0, -30),
                child: Image.asset(
                'assets/img/musicno.png',
                width: 200,
                height: 200,
              ),
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



