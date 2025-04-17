import 'package:flutter/material.dart';

class Achievement extends StatefulWidget {
  final int waterAmount;

  const Achievement({super.key, required this.waterAmount});

  //창 표시 여부
  @override
  State<Achievement> createState() => _AchievementState();
}

class _AchievementState extends State<Achievement> {
  bool isVisible = true;

  @override
  Widget build(BuildContext context) {
    return Visibility( // waterAmount 2000 이상 표시
      visible: isVisible && widget.waterAmount >= 2000,
      child: GestureDetector(
        onTap: () {
          setState(() {
            isVisible = false; // 클릭 시 창 숨김
          });
        },
        child: Stack(
          children: [
            Container(
              color: Colors.black. withAlpha(140), // 불투명 배경
            ),

            Center( //이모티콘
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/img/happy_face.png',
                    width: 150,
                    height: 110,
                  ),

                  const SizedBox(height: 20),

                  //달성 문구
                  const Text(
                    '하루 물 섭취량을 달성했어요!',
                    style: TextStyle(
                        fontSize: 20,
                        fontFamily: 'padauk',
                        color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}