import 'package:flutter/material.dart';
import 'package:lifefit/component/yrin_water/achievement.dart';
import 'package:lifefit/component/yrin_water/time_display.dart';
import 'package:lifefit/component/yrin_water/water_intake.dart';
import 'package:lifefit/component/yrin_water/water_graph.dart';
import 'package:lifefit/component/yrin_water/water_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WaterHome extends StatefulWidget {
  const WaterHome({super.key});

  @override
  State<WaterHome> createState() => _WaterHomeState();
}

class _WaterHomeState extends State<WaterHome> {
  final WaterService _waterService = WaterService();
  int _currentDailyIntake = 0;
  int _dailyWaterGoal = 2000; // 목표치 설정 (예시 값)
  bool _hasShownAchievement = false;
  // weeklyIntake 데이터 타입 변경: Map<int, double>
  Map<int, double> _weeklyIntake = {};

  @override
  void initState() {
    super.initState();
    _loadAllData(); // 모든 데이터를 한 번에 로드하도록 통합
  }

  Future<void> _loadAllData() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      // 사용자 ID가 없으면 로그인 페이지로 리다이렉트하거나 오류 처리
      print("Error: User not logged in.");
      return;
    }

    // 오늘 데이터 로드
    final todayData = await _waterService.getTodayIntake();
    // 주간 데이터 로드
    final weeklyData = await _waterService.getWeeklyIntake();
    // 달성 오버레이 표시 여부 로드
    final hasShown = await _waterService.hasShownAchievementToday(userId);


    if (!mounted) return; // 위젯이 마운트 해제되었다면 setState 호출 방지

    setState(() {
      _currentDailyIntake = todayData?.totalAmount ?? 0;
      _weeklyIntake = weeklyData;
      _hasShownAchievement = hasShown;
    });
  }

  Future<void> _handleAddWater(int amount) async {
    await _waterService.addWaterIntake(amount);
    // 데이터 추가 후 모든 데이터 재로드하여 UI 갱신
    await _loadAllData();
  }

  // 달성 오버레이가 보여졌음을 기록
  void _onAchievementShown() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    setState(() {
      _hasShownAchievement = true; // UI 상태 먼저 업데이트
    });
    await _waterService.markAchievementAsShown(userId); // Firestore에 기록
  }

  @override
  Widget build(BuildContext context) {
    // 목표 달성 여부 확인 로직
    final bool shouldShowAchievementOverlay =
        _currentDailyIntake >= _dailyWaterGoal && !_hasShownAchievement;

    return Scaffold(
      body: Stack(
        children: [
          // 물 섭취 UI
          WaterIntake(
            onAmountChanged: _handleAddWater,
            currentTotalAmount: _currentDailyIntake,
            dailyWaterGoal: _dailyWaterGoal,
          ),

          // 시간 표시
          Positioned(
            top: 320, // 위치 조정 필요시 변경
            left: 0,
            right: 0,
            child: const Center(child: TimeDisplay()),
          ),

          // 그래프
          Positioned(
            bottom: 125, // 위치 조정 필요시 변경
            left: 28,
            right: 28,
            height: 200, // 높이 조정 필요시 변경
            child: WaterGraph(
              weeklyIntake: _weeklyIntake, // Map<int, double> 타입으로 전달
              maxY: _dailyWaterGoal.toDouble(), // Y축 최대값은 목표치로 설정
            ),
          ),

          // 목표 달성 오버레이 (조건부 표시)
          if (shouldShowAchievementOverlay)
            Achievement(
              waterAmount: _currentDailyIntake,
              dailyWaterGoal: _dailyWaterGoal,
            ),
        ],
      ),
    );
  }
}