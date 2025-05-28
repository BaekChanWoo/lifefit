import 'package:flutter/material.dart';
import 'dart:developer';

class Achievement extends StatefulWidget {
  final int waterAmount; // 현재까지 마신 물의 양 (WaterProvider에서 옴)
  final int dailyWaterGoal;   // 일일 목표량 (WaterProvider에서 옴)
  final bool hasShown;
  final VoidCallback onAchievementShown;

  const Achievement({
    super.key,
    required this.waterAmount,
    required this.dailyWaterGoal,
    required this.hasShown,
    required this.onAchievementShown,
  });

  @override
  State<Achievement> createState() => _AchievementState();
}

class _AchievementState extends State<Achievement> {
  bool _isCurrentlyVisible = true; // 이 위젯의 로컬 표시 상태

  @override
  void initState() {
    super.initState();
    log('Achievement initState: waterAmount=${widget.waterAmount}, dailyWaterGoal=${widget.dailyWaterGoal}, hasShown=${widget.hasShown}', name: 'Achievement');

    // 초기 빌드 시 물의 양이 목표치 이상이고, 아직 표시되지 않았다면 창을 보여줌
    if (widget.waterAmount >= widget.dailyWaterGoal && !widget.hasShown) {
      _isCurrentlyVisible = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          widget.onAchievementShown(); // 부모에게 표시되었음을 알림
          log('Achievement: Triggered onAchievementShown callback.', name: 'Achievement');
        }
      });
    } else {
      _isCurrentlyVisible = false;
    }
  }

  @override
  void didUpdateWidget(covariant Achievement oldWidget) {
    super.didUpdateWidget(oldWidget);
    log('Achievement didUpdateWidget: oldWaterAmount=${oldWidget.waterAmount}, newWaterAmount=${widget.waterAmount}, oldGoal=${oldWidget.dailyWaterGoal}, newGoal=${widget.dailyWaterGoal}, hasShown=${widget.hasShown}', name: 'Achievement');

    // 물의 양이 목표에 도달했고, 이전에는 도달하지 않았으며, 아직 표시되지 않았다면
    if (widget.waterAmount >= widget.dailyWaterGoal &&
        oldWidget.waterAmount < oldWidget.dailyWaterGoal && // 이전 목표치 미달 상태에서 현재 목표치 이상으로
        !widget.hasShown) {
      log('Achievement didUpdateWidget: waterAmount reached goal, resetting visibility.', name: 'Achievement');
      setState(() {
        _isCurrentlyVisible = true;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          widget.onAchievementShown(); // 부모에게 '표시됨' 알림
        }
      });
    }
    // else if (widget.waterAmount < widget.dailyGoal && oldWidget.waterAmount >= oldWidget.dailyGoal) {
    //   // 이 부분은 지워졌습니다.
    //   log('Achievement didUpdateWidget: waterAmount below goal, resetting _isCurrentlyVisible.', name: 'Achievement');
    //   setState(() {
    //     _isCurrentlyVisible = false;
    //   });
    // }
  }

  @override
  Widget build(BuildContext context) {
    // 최종 가시성 조건: 이 위젯의 로컬 상태, 물량과 목표치, 그리고 부모의 hasShown 상태 모두 만족해야 함
    final bool showOverlay = _isCurrentlyVisible && widget.waterAmount >= widget.dailyWaterGoal && !widget.hasShown;
    log('Achievement build: showOverlay=$showOverlay (isCurrentlyVisible=$_isCurrentlyVisible, waterAmount=${widget.waterAmount}, dailyWaterGoal=${widget.dailyWaterGoal}, hasShown=${widget.hasShown})', name: 'Achievement');

    return Visibility(
      visible: showOverlay,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _isCurrentlyVisible = false; // 클릭 시 이 위젯 자체를 숨김
            log('Achievement tapped: Hiding overlay.', name: 'Achievement');
          });
        },
        child: Stack(
          children: [
            Container(
              color: Colors.black.withAlpha(140), // 불투명 배경
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/img/happy_face.png', // 이미지 경로 확인
                    width: 150,
                    height: 110,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    '하루 물 섭취량을 달성했어요!',
                    style: TextStyle(
                        fontSize: 20,
                        fontFamily: 'padauk', // 폰트 경로 확인
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