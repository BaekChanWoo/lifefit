import 'package:flutter/material.dart';
import 'package:lifefit/component/yrin_water/achievement.dart';
import 'package:lifefit/component/yrin_water/time_display.dart';
import 'package:lifefit/component/yrin_water/water_intake.dart';
import 'package:lifefit/component/yrin_water/water_graph.dart';
import 'package:lifefit/provider/water_provider.dart';
import 'dart:developer';
import 'package:provider/provider.dart';

class WaterHome extends StatefulWidget {
  const WaterHome({super.key});

  @override
  State<WaterHome> createState() => _WaterHomeState();
}

class _WaterHomeState extends State<WaterHome> {
  bool _hasShownAchievement = false;
  late WaterProvider _waterProvider;

  @override
  void initState() {
    super.initState();
    _waterProvider = Provider.of<WaterProvider>(context, listen: false);
    log('WaterHome initState: Starting WaterProvider streams.', name: 'WaterHome');
    _waterProvider.startListeningToWaterData();
  }

  @override
  void dispose() {
    log('WaterHome dispose: Stopping WaterProvider streams.', name: 'WaterHome');
    _waterProvider.stopListeningToWaterData();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WaterProvider>(
      builder: (context, manager, child) {
        final bool shouldShowAchievementOverlay =
            manager.currentDailyIntake >= manager.dailyWaterGoal && !_hasShownAchievement;

        // 물 목표량 미달 시 _hasShownAchievement 리셋 (팝업이 다시 뜰 수 있도록)
        if (manager.currentDailyIntake < manager.dailyWaterGoal && _hasShownAchievement) {
          setState(() {
            _hasShownAchievement = false;
          });
        }

        return Scaffold(
          // WaterHome에서는 AppBar가 필요 없다는 요청을 반영하여, 여기에 AppBar를 추가하지 않습니다.
          // WaterIntake 위젯에 AppBar 대체 UI가 있으므로 중복을 피합니다.
          body: Stack(
            children: [
              // WaterIntake 위젯
              // initialWaterAmount 대신 currentTotalAmount를 사용합니다.
              WaterIntake(
                onAmountChanged: (amount) {
                  manager.addWater(amount); // WaterProvider의 addWater 호출
                },
                currentTotalAmount: manager.currentDailyIntake, // WaterProvider의 현재 섭취량 전달
                dailyWaterGoal: manager.dailyWaterGoal, // WaterProvider의 목표량 전달
              ),

              // TimeDisplay 위젯
              // Stack 내부의 Positioned로 배치
              Positioned(
                top: 320, // WaterIntake 위젯 하단에 오도록 위치 조정 (조절 필요)
                left: 0,
                right: 0,
                child: const Center(child: TimeDisplay()), // TimeDisplay도 Center로 감싸면 보기 좋습니다.
              ),

              // WaterGraph 위젯
              // Stack 내부의 Positioned로 배치
              Positioned(
                bottom: 125,
                left: 28,
                right: 28,
                height: 200,
                child: WaterGraph(
                  weeklyIntake: manager.weeklyIntake, // WaterProvider의 주간 섭취량 전달
                  maxY: manager.dailyWaterGoal.toDouble(), // 그래프 스케일링 등을 위해 목표량 전달
                ),
              ),

              // Achievement 위젯 (목표 달성 오버레이)
              if (shouldShowAchievementOverlay)
                Achievement(
                  waterAmount: manager.currentDailyIntake, // WaterProvider의 현재 섭취량 전달
                  dailyWaterGoal: manager.dailyWaterGoal, // Achievement 위젯에 목표량 전달
                  hasShown: _hasShownAchievement, // WaterHome의 상태 전달
                  onAchievementShown: () {
                    setState(() {
                      _hasShownAchievement = true;
                    });
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}