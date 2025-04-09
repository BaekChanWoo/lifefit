import 'package:flutter/material.dart';
import 'package:lifefit/component/community/mypage.dart';
import 'package:lifefit/component/community/mypage_custom_button.dart';

// 마이페이지
class MainMyPage extends StatefulWidget {
  const MainMyPage({super.key});

  @override
  State<MainMyPage> createState() => _MainMyPageState();
}

class _MainMyPageState extends State<MainMyPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
            MyPage(),
            Buttons(),
        ],
      ),
    );
  }
}
