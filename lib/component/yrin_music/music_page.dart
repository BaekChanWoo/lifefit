import 'package:flutter/material.dart';
import 'package:lifefit/component/yrin_music/youtube_search.dart';

class MusicPage extends StatelessWidget {
  final String categoryImages;
  final String searchKeyword;

  const MusicPage({super.key, required this.categoryImages, required this.searchKeyword});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('playlist',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(
          color: Colors.white, // 뒤로 가기 화살표 색상을 하얀색으로 설정
        ),

      ),
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  color: Colors.black,
                  padding: const EdgeInsets.all(12.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: SizedBox(
                      width: 150,
                      height: 130,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: Image.asset(
                          categoryImages,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 0.0),
                  child: Container(
                    width: double.infinity,
                    height: 40,//
                    color: Colors.black,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                      const Text(
                      '전체 듣기',
                      style: TextStyle(color: Colors.white, fontSize: 18.0),
                        ),
                        const SizedBox(width: 8.0),
                        const Text(
                            '▶',
                            style: TextStyle(color: Colors.white, fontSize: 18.0),
                        ),
                      ]
                    )
                  ),
                ),
                )
              ],
            ),
          ),
          Positioned(
            top: 200, //
            left: 0,
            right: 0,
            bottom: 0,
            child:YoutubeSearch(searchKeyword: searchKeyword),
          ),
        ],
      ),
    );
  }
}
