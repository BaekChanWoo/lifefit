import 'package:flutter/material.dart';
import 'dart:async';

class Healthtopic extends StatefulWidget {
  const Healthtopic({super.key});

  @override
  State<Healthtopic> createState() => _HealthtopicState();
}

class _HealthtopicState extends State<Healthtopic> {
  // 뉴스 테스트 이미지 에셋 경로
  final String test1Image = 'assets/img/test1.png';
  final String test2Image = 'assets/img/test2.png';

  // 최상단 이미지 슬라이더/인디케이터 요소
  final List<int> pages = List.generate(4, (index) => index); //카드 인덱스
  final PageController controller = PageController(initialPage: 0); //카드 페이지 컨트롤러
  int curruntPage = 0; // 카드 페이지 정수

  @override // 카드 슬라이더 타이머
  void initState() {
    super.initState();
    Timer.periodic(Duration(seconds: 7), (Timer timer) {
      //타이머
      if (controller.hasClients && controller.page != null) {
        // PageController가 PageView에 연결되어 있고, 페이지 정보가 있는 경우에만 실행
        if (controller.page! < pageimgs.length - 1) {
          // 현재 페이지가 마지막 페이지보다 이전 페이지인 경우
          controller.nextPage(
            // 다음 페이지 이동
            duration: Duration(milliseconds: 350), // 애니메이션 지속 시간
            curve: Curves.easeIn,
          );
        } else {
          // 현재 페이지가 마지막 페이지인 경우
          controller.animateToPage(
            // 첫 번째 페이지 이동
            0,
            duration: Duration(milliseconds: 350), // 첫 페이지로 이동하는시간
            curve: Curves.easeIn,
          );
        }
      }
    });
  }

  @override // 미사용시 컨트롤러 리소스해제
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  // 데이터 리스트 정의
  final List<String> pageimgs = [
    'assets/img/test2.png',
    'assets/img/test2.png',
    'assets/img/test2.png',
    'assets/img/test2.png',
  ]; //슬라이더 이미지

  final List<String> pageTexts = [
    '첫 번째 페이지 텍스트',
    '두 번째 페이지 텍스트 내용',
    '세 번째 페이지의 아주 긴 텍스트입니다. 이 텍스트는 컨테이너 너비에 맞춰 자동으로 줄바꿈될 것입니다.',
    '네 번째 페이지 짧은 텍스트',
  ]; //슬라이더 텍스트

  final List<Map<String, dynamic>> realTimeTopics = [
    {
      'image': 'assets/img/test1.png',
      'title': '피클·오이지 즐겨 먹었는데…뜻밖의 연구 결과에',
      'description': '한국뉴스 | 25.04.01',
    },
    {
      'image': 'assets/img/test1.png',
      'title': '잠이 보약이라는 말, 과학적으로 근거 있을까?',
      'description': '헬스조선 | 25.04.02',
    },
    {
      'image': 'assets/img/test1.png',
      'title': '잠이 보약이라는 말, 과학적으로 근거 있을까?',
      'description': '헬스조선 | 25.04.02',
    },
    {
      'image': 'assets/img/test1.png',
      'title': '잠이 보약이라는 말, 과학적으로 근거 있을까?',
      'description': '헬스조선 | 25.04.02',
    },
    // ... 더 많은 토픽 데이터
  ]; // 실시간 토픽

  final List<Map<String, dynamic>> mealRecommendations = [
    {
      'image': 'assets/img/test1.png',
      'title': '상큼한 샐러드 레시피',
      'recipe': 'XXX 레시피',
    },
    {
      'image': 'assets/img/test1.png',
      'title': '건강한 스무디',
      'recipe': 'YYY 레시피',
    },
    {
      'image': 'assets/img/test1.png',
      'title': '건강한 스무디',
      'recipe': 'YYY 레시피',
    },
    {
      'image': 'assets/img/test1.png',
      'title': '건강한 스무디',
      'recipe': 'YYY 레시피',
    },
    // ... 더 많은 식사 추천 데이터
  ]; // 식사 추천

  final List<Map<String, dynamic>> videoContents = [
    {
      'image': 'assets/img/test1.png',
      'title': '\'저탄고지\' 다이어트 효과 있을까? 제대로 알고 시작하세요',
      'nutritionist': '△△△ 영양사',
    },
    {
      'image': 'assets/img/test1.png',
      'title': '장 건강을 위한 최고의 음식',
      'nutritionist': '○○○ 의사',
    },
    {
      'image': 'assets/img/test1.png',
      'title': '장 건강을 위한 최고의 음식',
      'nutritionist': '○○○ 의사',
    },
    {
      'image': 'assets/img/test1.png',
      'title': '장 건강을 위한 최고의 음식',
      'nutritionist': '○○○ 의사',
    },
    // ... 더 많은 영상 데이터
  ]; // 영상

  final List<Map<String, dynamic>> expertColumns = [
    {
      'image': 'assets/img/test1.png',
      'title': '\'물 단식\' 다이어트 유행? 건강 지키려면 차라리 \'이것\'',
      'expert': 'OOO 박사',
    },
    {
      'image': 'assets/img/test1.png',
      'title': '현대인을 위한 스트레스 관리법',
      'expert': '△△△ 심리상담가',
    },
    // ... 더 많은 전문가 칼럼 데이터
  ]; // 전문가칼럼

  // 공통 위젯 생성 함수 정의
  Widget _buildContentCard(Map<String, dynamic> data, String contentType) {
    switch (contentType) {
      case 'realTimeTopic': // 실시간 토픽 섹션
        return Card(
          shape: ContinuousRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          elevation: 0.0,
          color: Colors.white,
          margin: EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.asset(data['image'], width: 118.0, height: 90.0, fit: BoxFit.cover),
              ),
              SizedBox(width: 8.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data['title'], style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis, maxLines: 2),
                    SizedBox(height: 8.0),
                    Text(data['description']),
                  ],
                ),
              ),
            ],
          ),
        );
      case 'mealRecommendation': // 레시피 섹션
        return Card(
          shape: ContinuousRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          elevation: 4.0,
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.asset(data['image'], width: 154.0, height: 154.0, fit: BoxFit.cover),
                ),
                SizedBox(height: 8.0),
                Text(data['title'], textAlign: TextAlign.left),
                SizedBox(height: 8.0),
                Text(data['recipe']),
              ],
            ),
          ),
        );
      case 'videoContent': // 영상 섹션
        return Card(
          shape: ContinuousRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          elevation: 0.0,
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4.0),
                    child: Image.asset(data['image'], width: 290.0, height: 164.0, fit: BoxFit.cover),
                  ),
                  Icon(Icons.play_circle_fill, color: Colors.white, size: 60.0),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: 274.0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data['title'], style: TextStyle(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis, maxLines: 2),
                      SizedBox(height: 8.0),
                      Text(data['nutritionist']),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      case 'expertColumn': // 전문가 섹션
        return Card(
          shape: ContinuousRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          elevation: 2.0,
          color: Colors.white,
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.asset(data['image'], width: 80.0, height: 130.0, fit: BoxFit.cover),
              ),
              SizedBox(width: 8.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data['title'], style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(data['expert']),
                  ],
                ),
              ),
            ],
          ),
        );
      default:
        return Container(); // 기본적으로 빈 컨테이너 반환
    }
  }

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
      ), // 상단 GNB

      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20), // 마진
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //최상단 이미지 슬라이드 뉴스
            Container(
              width: double.infinity,
              height: 320,
              child: PageView.builder(
                controller: controller,
                itemCount: pageimgs.length,
                onPageChanged: (page) {
                  setState(() {
                    curruntPage = page;
                    print(page);
                  });
                },
                itemBuilder: (context, index) {
                  return Padding(
                    // 카드 주변에 약간의 간격을 주기 위해 Padding 추가
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        // 카드 모서리 둥글게 설정
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      elevation: 4.0, // 그림자 효과
                      child: Stack(
                        fit: StackFit.expand, // Stack이 Card의 크기에 맞춰지도록 설정
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16.0),
                            child: Image.asset(
                              pageimgs[index], // 해당 페이지(인덱스)의 이미지
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            left: 16,
                            bottom: 16,
                            right: 16,
                            child: Text(
                              pageTexts[index], // 해당 페이지(인덱스)의 텍스트
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ), // 카드
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (num i = 0;
                i < pageimgs.length;
                i++) // pageimgs의 길이에 맞춰 인디케이터 생성
                  Container(
                    margin: EdgeInsets.all(3),
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: curruntPage == i
                          ? Colors.blue
                          : Colors.grey.withValues(alpha: 0.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
              ],
            ), // 인디케이터
            SizedBox(height: 48.0),

            // 실시간 토픽 섹션
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text('실시간 토픽',
                  style:
                  TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold)),
            ),
            SizedBox(
              height: 424.0,
              child: ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                itemCount: realTimeTopics.length,
                itemBuilder: (context, index) {
                  return _buildContentCard(realTimeTopics[index], 'realTimeTopic');
                },
              ),
            ),
            SizedBox(height: 48.0),

            // 식사 추천 섹션
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text('식사로 챙기는 건강!',
                  style:
                  TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold)),
            ),
            SizedBox(
              height: 250.0,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: mealRecommendations.length,
                itemBuilder: (context, index) {
                  return _buildContentCard(mealRecommendations[index], 'mealRecommendation');
                },
              ),
            ),
            SizedBox(height: 48.0),

            // 영상 섹션
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text('영상으로 보는 건강지식',
                  style:
                  TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold)),
            ),
            SizedBox(
              height: 260.0,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: videoContents.length,
                itemBuilder: (context, index) {
                  return _buildContentCard(videoContents[index], 'videoContent');
                },
              ),
            ),
            SizedBox(height: 48.0),

            // 전문가 칼럼 섹션
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text('전문가와 함께하는 건강 이야기',
                  style:
                  TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold)),
            ),
            SizedBox(
              height: 280.0,
              child: ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                itemCount: expertColumns.length,
                itemBuilder: (context, index) {
                  return _buildContentCard(expertColumns[index], 'expertColumn');
                },
              ),
            ),
            SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }
}