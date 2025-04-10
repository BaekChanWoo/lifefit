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
      appBar: AppBar(
        leading: Icon(Icons.arrow_back_ios),
        title: Text('건강토픽', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),textAlign: TextAlign.center),
        actions: [
          IconButton(icon: Icon(Icons.menu), onPressed: () {}),
        ],
      ),


      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20),//마진
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // 최 상단 이미지 및 텍스트
            Stack(
              alignment: Alignment.center,
              children: [
                Image.asset(test1Image, width: double.infinity, fit: BoxFit.cover),
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
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text('실시간 토픽', style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
            ),
            Card(
              margin: EdgeInsets.all(8.0),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Image.asset(test1Image, width: 80.0, height: 60.0, fit: BoxFit.cover),
                    SizedBox(width: 8.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('최근 오이 가격 급등했는데...', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('한국뉴스 | 25.04.01'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Card(
              margin: EdgeInsets.all(8.0),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Image.asset(test1Image, width: 80.0, height: 60.0, fit: BoxFit.cover),
                    SizedBox(width: 8.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('최근 오이 가격 급등했는데... 못 참겠다! 오이 레시피', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('맛있는요리 | 25.03.28'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // ... (나머지 실시간 토픽 카드들 추가)
            SizedBox(height: 48.0),


            // 식사/운동 추천 섹션
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text('식사로 챙기는 건강!', style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
            ),
            SizedBox(
              height: 120.0,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 2, // 예시 아이템 수
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Card(
                      margin: EdgeInsets.all(8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Image.asset(test1Image, width: 80.0, height: 60.0, fit: BoxFit.cover),
                            SizedBox(height: 8.0),
                            Text('상큼한 샐러드 레시피', textAlign: TextAlign.center),
                          ],
                        ),
                      ),
                    );
                  } else {
                    return Card(
                      margin: EdgeInsets.all(8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Image.asset('assets/exercise.jpg', width: 80.0, height: 60.0, fit: BoxFit.cover), // 예시 운동 이미지
                            SizedBox(height: 8.0),
                            Text('오늘의 추천 운동', textAlign: TextAlign.center),
                          ],
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
            SizedBox(height: 48.0),


            // 운동 관련 영상 및 화보 섹션
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text('영상으로 보는 건강지식', style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
            ),
            SizedBox(
              height: 150.0,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 5, // 예시 아이템 수
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.asset(test1Image, width: 150.0, height: 100.0, fit: BoxFit.cover),
                            Icon(Icons.play_circle_fill, color: Colors.white.withOpacity(0.8), size: 30.0),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('초보자를 위한 필라테스', style: TextStyle(fontSize: 12.0)),
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
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text('전문가와 함께하는 건강 이야기', style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
            ),
            Card(
              margin: EdgeInsets.all(8.0),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: AssetImage(test2Image),
                    ),
                    SizedBox(width: 8.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('\'물 단식\' 다이어트 유행? 건강 지키려면 차라리 \'이것\'', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('OOO 박사'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Card(
              margin: EdgeInsets.all(8.0),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: AssetImage(test2Image),
                    ),
                    SizedBox(width: 8.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('\'저탄고지\' 다이어트 효과 있을까? 제대로 알고 시작하세요', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('△△△ 영양사'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }
}