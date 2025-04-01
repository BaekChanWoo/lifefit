import 'package:flutter/material.dart';

// 계속 반복되는 하단바
class MainBottomNavigationBar extends StatefulWidget {
  const MainBottomNavigationBar({super.key});

  @override
  State<MainBottomNavigationBar> createState() => _MainBottomNavigationBarState();
}

class _MainBottomNavigationBarState extends State<MainBottomNavigationBar> {
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
        type: BottomNavigationBarType.fixed, // 아이콘 4개 이상일 때 필요
        items: [
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
            label: "만남",
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
