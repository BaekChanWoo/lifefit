import 'package:flutter/material.dart';
import 'package:lifefit/component/community/mypage.dart';
import 'package:lifefit/component/community/mypage_custom_button.dart';
import 'package:lifefit/component/community/mypage_feed_number.dart';
import 'package:lifefit/const/colors.dart';

// 마이페이지
class MainMyPage extends StatefulWidget {
  const MainMyPage({super.key});

  @override
  State<MainMyPage> createState() => _MainMyPageState();
}
// Sliver는 스크롤 가능한 영역의 부분을 나타냄
// SliverList = 스크롤 가능한 리스트
class _MainMyPageState extends State<MainMyPage> {
  int postCount = 50; // 게시물 수를 동적으로 관리하기 위한 변수

  @override
  Widget build(BuildContext context) {
    return Container(
      child: NestedScrollView( // 헤더와 바디의 스크롤을 조율
        headerSliverBuilder: (context , innerBoxIsScrolled){
          return [
            SliverList( // 마이페이지와 버튼 순차적으로 배치
                delegate: SliverChildListDelegate([MyPage() , Buttons() , MyPageFeedNumber(),]),
            ),
          ];
        },
        body: CustomScrollView( // 여러 Sliver 기반 위젯을 조합해 스크롤 UI 구현
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.only(top: 20.0), // 상단 여백 추가
              sliver: postCount > 0 ? SliverGrid(
                // 고정된 열 수를 가진 그리드 레이아웃을 정의
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  //crossAxisSpacing: 1.0, // 열 사이의 간격 1.0픽셀
                  //mainAxisSpacing: 1.0, // 행 사이의 간격 1,0 픽셀
                ),
                delegate: SliverChildBuilderDelegate(
                      (context, index) =>
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                //color: PRIMARY_COLOR,
                                color: Colors.black,
                                width: 1.0,
                              ),
                            ),
                            child: Image.asset('assets/img/gridimg.jpg'
                                                , fit: BoxFit.cover,
                                                ),
                          ),
                          // Container(color: Colors.blue,),
                  childCount: postCount,
                ),
              ) : SliverToBoxAdapter(
                // CustomScrollView 안에서 스크롤 가능한 리스트,그리드 외에 고정된 ui 요소를 추가하고 싶을 때 사용
                child: Center( // 일반 위젯(center)을 Sliver 처럼 동작하도록 감싸는 어댑터
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 80.0),
                    child: ElevatedButton(
                      onPressed: () {
                        // 글쓰기 기능 구현 (예: 새로운 게시물 추가)
                        setState(() {
                          postCount = 1; // 테스트용으로 1개 추가
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: PRIMARY_COLOR,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30.0,
                          vertical: 15.0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: const Text(
                        '글쓰기',
                        style: TextStyle(fontSize: 16.0),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}