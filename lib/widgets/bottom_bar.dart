import 'package:flutter/material.dart';
import 'package:lifefit/const/colors.dart';

// 계속 반복되는 하단바
class MainBottomNavigationBar extends StatefulWidget {
  const MainBottomNavigationBar({super.key});

  @override
  State<MainBottomNavigationBar> createState() => _MainBottomNavigationBarState();
}

class _MainBottomNavigationBarState extends State<MainBottomNavigationBar> {
  int _selectedIndex = 0; // 현재 선택된 탭의 인덱스

  /*
  // 화면 목록
  final List<Widget> _screens = [
    // 나중에 만들 페이지 목록
  ];
  */

  void _onItemTapped(int index){
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 11, // 흐림 정도
            spreadRadius: 2, // 확산 정도
            offset: Offset(0, -3), // 위쪽 방향으로 그림자 이동
          ),
        ],
      ),

      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedIconTheme: IconThemeData(color: PRIMARY_COLOR , size: 28),
        unselectedIconTheme: IconThemeData(color: Colors.black54, size: 24),
        type: BottomNavigationBarType.fixed, // 아이콘 4개 이상일 때 필요

        items: [
          BottomNavigationBarItem(
            icon: const Icon(
                Icons.home
            ) ,
            label: "홈",
          ),
          BottomNavigationBarItem(
            icon: const Icon(
              Icons.bolt,
            ) ,
            label: "번개",
          ),
          BottomNavigationBarItem(
            icon: const Icon(
                Icons.calendar_month
            ) ,
            label: "만남",
          ),
          BottomNavigationBarItem(
            icon: const Icon(
                Icons.chat_bubble_outline
            ) ,
            label: "커뮤니티",
          ),
          BottomNavigationBarItem(
            icon: const Icon(
              Icons.play_circle_filled,
            ) ,
            label: "노래",
          ),
        ],
      ),
    );
  }
}
