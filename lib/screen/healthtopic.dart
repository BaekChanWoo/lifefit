import 'package:flutter/material.dart';

class Healthtopic extends StatefulWidget {
  const Healthtopic({super.key});

  @override
  State<Healthtopic> createState() => _HealthtopicState();
}

class _HealthtopicState extends State<Healthtopic> {
  // 뉴스 테스트 이미지 에셋 경로
  final String test1Image = 'assets/img/test1.png';
  final String test2Image = 'assets/img/test2.png';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Center(
          child: Text(
            '건강토픽',
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
        actions: [
          IconButton(icon: Icon(Icons.menu), onPressed: () {}), // 메뉴...
        ],
      ),


      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20), // 마진
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [


            // 최 상단 이미지 및 텍스트
            Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect( // 이미지 모서리를 둥글게 처리하기 위해 ClipRRect 사용
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.asset(test1Image,
                      width: double.infinity,
                      fit: BoxFit.cover),
                ),
                Image.asset(test1Image,
                    width: double.infinity, fit: BoxFit.cover),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    '오늘 저녁은 뭘 먹지? 맛있고 건강하게 즐기는 특별한 레시피',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            SizedBox(height: 48.0),


            // 실시간 토픽 섹션
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text('실시간 토픽',
                  style:
                      TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
            ),
            SizedBox(
                height: 500.0,
                child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: 4, // 예시 아이템 수
                    itemBuilder: (context, index) {
                      return Card(shape: ContinuousRectangleBorder(// [모서리 살짝 둥글게 사용]
                        borderRadius: BorderRadius.circular(16.0), // [둥글기 설정]
                      ),
                        elevation: 0.0, //그림자 깊이
                        color: Colors.white, // [색상 지정]
                        margin: EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              children: [
                                ClipRRect( // 이미지 모서리를 둥글게 처리하기 위해 ClipRRect 사용
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Image.asset(
                                    test1Image,
                                    width: 118.0,
                                    height: 90.0,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                SizedBox(width: 8.0),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('피클·오이지 즐겨 먹었는데…뜻밖의 연구 결과에 ㄴㄴㄴㄴㄴㄴㄴㄴㄴㄴㄴㄴㄴㄴㄴㄴㄴㄴㄴㄴㄴㄴㄴㄴㄴㄴㄴㄴㄴㄴㄴㄴㄴㄴㄴㄴㄴㄴㄴㄴㄴㄴ',
                                          style: TextStyle(fontSize: 15.0,
                                              fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis,
                                          maxLines: 2),
                                      SizedBox(height: 8.0),
                                      Text('한국뉴스 | 25.04.01'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                    })),
            SizedBox(height: 48.0),

            // 식사 추천 섹션
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text('식사로 챙기는 건강!',
                  style:
                      TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
            ),
            SizedBox(
                height: 300.0,
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 5, // 예시 아이템 수
                    itemBuilder: (context, index) {
                      return Card(shape: ContinuousRectangleBorder(// [모서리 살짝 둥글게 사용]
                        borderRadius: BorderRadius.circular(16.0), // [둥글기 설정]
                      ),
                        elevation: 4.0, //그림자 깊이
                        color: Colors.white, // [색상 지정]

                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [ClipRRect( // 이미지 모서리를 둥글게 처리하기 위해 ClipRRect 사용
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.asset(test1Image,
                                  width: 154.0,
                                  height: 154.0,
                                  fit: BoxFit.cover),
                              ),
                              SizedBox(height: 8.0),
                              Text('상큼한 샐러드 레시피', textAlign: TextAlign.center),
                            ],
                          ),
                        ),
                      );
                    })),
            SizedBox(height: 48.0),

            // 영상 섹션
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text('영상으로 보는 건강지식',
                  style:
                      TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
            ),
            SizedBox(
              height: 290.0,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 5, // 예시 아이템 수
                itemBuilder: (context, index) {
                  return Card(
                    shape: ContinuousRectangleBorder(// [모서리 살짝 둥글게 사용]
                      borderRadius: BorderRadius.circular(16.0), // [둥글기 설정]
                    ),
                    elevation: 0.0, //그림자 깊이
                    color: Colors.white, // [색상 지정]

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            ClipRRect( // 이미지 모서리를 둥글게 처리하기 위해 ClipRRect 사용
                              borderRadius: BorderRadius.circular(4.0),
                              child: Image.asset(test1Image,
                                  width: 290.0,
                                  height: 164.0,
                                  fit: BoxFit.cover),
                            ),
                            Icon(Icons.play_circle_fill,
                                color: Colors.white, size: 60.0),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            width: 274.0,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('\'저탄고지\' 다이어트 효과 있을까? 제대로 알고 시작하세요sssssssssssssssssssssssssssssssssssssssss',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),overflow: TextOverflow.ellipsis,
                                    maxLines: 2),
                                SizedBox(height: 8.0),
                                Text('△△△ 영양사'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 48.0),

            // 전문가 칼럼 섹션
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text('전문가와 함께하는 건강 이야기',
                  style:
                      TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
            ),
            SizedBox(
                height: 300.0,
                child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: 2, // 예시 아이템 수
                    itemBuilder: (context, index) {
                      return Card(shape: ContinuousRectangleBorder(// [모서리 살짝 둥글게 사용]
                        borderRadius: BorderRadius.circular(16.0), // [둥글기 설정]
                      ),
                        elevation: 2.0, //그림자 깊이
                        color: Colors.white, // [색상 지정]
                          child: Row(
                            children: [
                              ClipRRect( // 이미지 모서리를 둥글게 처리하기 위해 ClipRRect 사용
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.asset(test1Image,
                                    width: 80.0,
                                    height: 130.0,
                                    fit: BoxFit.cover),
                              ),
                              SizedBox(width: 8.0),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('\'물 단식\' 다이어트 유행? 건강 지키려면 차라리 \'이것\'',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    Text('OOO 박사'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                    })),
            SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }
}
