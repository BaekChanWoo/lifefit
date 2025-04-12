import 'package:flutter/material.dart';
import 'package:lifefit/const/colors.dart';


// 계속 반복되는 하단바
class MainBottomNavigationBar extends StatelessWidget {
  final int selectedIndex;          // 현재 누른 페이지 번호
  final Function(int) onItemTapped; // 탭을 누루면 HomeScreen의 콜백 함수 호출
  final bool isContainerPage;       // 컨테이너 페이지 여부(세부 페이지 여부에 따라 선택된 탭의 스타일 조정)

  const MainBottomNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
    this.isContainerPage = false,
});

  @override
  Widget build(BuildContext context) {
    return  Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade300,
                blurRadius: 11,         // 흐림 정도
                spreadRadius: 2,        // 확산 정도
                offset: Offset(0, -3),  // 위쪽 방향으로 그림자 이동
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: selectedIndex,
            onTap: onItemTapped, // 탭 클릭시 상위 위젯의 호출
            selectedIconTheme: isContainerPage ? const IconThemeData(color: Colors.black54 , size: 28) // 선택 해제
                                               : const IconThemeData(color: PRIMARY_COLOR , size: 28), // 기본 선택
            unselectedIconTheme: const IconThemeData(color: Colors.black54, size: 24),
            type: BottomNavigationBarType.fixed, // 아이콘 4개 이상일 때 필요

            items: const [
              BottomNavigationBarItem(
                icon: Icon(
                    Icons.home
                ) ,
                label: "홈",
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.bolt,
                ) ,
                label: "번개",
              ),
              BottomNavigationBarItem(
                icon: Icon(
                    Icons.calendar_month
                ) ,
                label: "캘린더",
              ),
              BottomNavigationBarItem(
                icon: Icon(
                    Icons.chat_bubble_outline
                ) ,
                label: "커뮤니티",
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.play_circle_filled,
                ) ,
                label: "노래",
              ),
            ],
          ),
    );
  }
}
