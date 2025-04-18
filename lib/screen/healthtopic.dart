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
  final PageController controller =
      PageController(initialPage: 0); //카드 페이지 컨트롤러
  int curruntPage = 0; // 카드 페이지 정수

  // 이미지 테스트
  final List<String> pageimgs = [
    'assets/image1.jpg',
    'assets/image2.jpg',
    'assets/image3.jpg',
    'assets/image4.jpg',
  ];
  //텍스트 테스트
  final List<String> pageTexts = [
    '첫 번째 페이지 텍스트',
    '두 번째 페이지 텍스트 내용',
    '세 번째 페이지의 아주 긴 텍스트입니다. 이 텍스트는 컨테이너 너비에 맞춰 자동으로 줄바꿈될 것입니다.',
    '네 번째 페이지 짧은 텍스트',
  ];

  @override // 카드 슬라이더 타이머
  void initState() {
    super.initState();
    Timer.periodic(Duration(seconds: 5), (Timer timer) {
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
                                color: Colors.black,
                                fontSize: 16.0,
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
                      TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
            ),
            SizedBox(
                height: 424.0,
                child: ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    itemCount: 4, // 예시 아이템 수
                    itemBuilder: (context, index) {
                      return Card(
                        shape: ContinuousRectangleBorder(
                          // [모서리 살짝 둥글게 사용]
                          borderRadius: BorderRadius.circular(16.0), // [둥글기 설정]
                        ),
                        elevation: 0.0,
                        //그림자 깊이
                        color: Colors.white,
                        // [색상 지정]
                        margin: EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            ClipRRect(
                              // 이미지 모서리를 둥글게 처리하기 위해 ClipRRect 사용
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
                                  Text('피클·오이지 즐겨 먹었는데…뜻밖의 연구 결과에',
                                      style: TextStyle(
                                          fontSize: 15.0,
                                          fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.ellipsis,
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
                height: 250.0,
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 5, // 예시 아이템 수
                    itemBuilder: (context, index) {
                      return Card(
                        shape: ContinuousRectangleBorder(
                          // [모서리 살짝 둥글게 사용]
                          borderRadius: BorderRadius.circular(16.0), // [둥글기 설정]
                        ),
                        elevation: 4.0, //그림자 깊이
                        color: Colors.white, // [색상 지정]

                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              ClipRRect(
                                // 이미지 모서리를 둥글게 처리하기 위해 ClipRRect 사용
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.asset(test1Image,
                                    width: 154.0,
                                    height: 154.0,
                                    fit: BoxFit.cover),
                              ),
                              SizedBox(height: 8.0),
                              Text('상큼한 샐러드 레시피', textAlign: TextAlign.left),
                              SizedBox(height: 8.0),
                              Text('XXX레시피')
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
              height: 260.0,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 5, // 예시 아이템 수
                itemBuilder: (context, index) {
                  return Card(
                    shape: ContinuousRectangleBorder(
                      // [모서리 살짝 둥글게 사용]
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
                            ClipRRect(
                              // 이미지 모서리를 둥글게 처리하기 위해 ClipRRect 사용
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
                                Text('\'저탄고지\' 다이어트 효과 있을까? 제대로 알고 시작하세요',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
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
                height: 280.0,
                child: ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    itemCount: 2, // 예시 아이템 수
                    itemBuilder: (context, index) {
                      return Card(
                        shape: ContinuousRectangleBorder(
                          // [모서리 살짝 둥글게 사용]
                          borderRadius: BorderRadius.circular(16.0), // [둥글기 설정]
                        ),
                        elevation: 2.0, //그림자 깊이
                        color: Colors.white, // [색상 지정]
                        child: Row(
                          children: [
                            ClipRRect(
                              // 이미지 모서리를 둥글게 처리하기 위해 ClipRRect 사용
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
