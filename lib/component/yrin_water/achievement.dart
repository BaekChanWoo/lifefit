import 'package:flutter/material.dart';

class Achievement extends StatefulWidget {
  final int waterAmount;
  final bool hasShown;
  final VoidCallback onAchievementShown;

  const Achievement({super.key,
    required this.waterAmount,
  required this.hasShown,
  required this.onAchievementShown,

  });

  //창 표시 여부
  @override
  State<Achievement> createState() => _AchievementState();
}

class _AchievementState extends State<Achievement> {
  bool isVisible = true;
  bool _hasShown = false;

  @override
  void initState() {
    super.initState();
    // 초기 빌드 시 물의 양이 2000 이상이고, 아직 표시되지 않았다면 창을 보여줌
    if (widget.waterAmount >= 2000 && !widget.hasShown) {
      Future.delayed(Duration.zero, () {
        if (mounted) {
          widget.onAchievementShown(); // 부모에게 표시
        }
      });
    } else {
      isVisible = false; // 초기 상태에서 안 보여줌
    }
  }


  @override
  Widget build(BuildContext context) {
    return Visibility( // waterAmount 2000 이상 표시
      visible: isVisible && widget.waterAmount >= 2000 && !_hasShown,
      child: GestureDetector(
        onTap: () {
          setState(() {
            isVisible = false; //클릭 시 창 숨기기
            _hasShown = true; // 창이 표시됨 기록
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