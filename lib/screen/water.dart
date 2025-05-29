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
  final int _dailyWaterGoal = 2000;
  Map<int, double> _weeklyIntake = {};

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      print("Error: User not logged in.");
      return;
    }

    final todayData = await _waterService.getTodayIntake();
    final weeklyData = await _waterService.getWeeklyIntake();

    if (!mounted) return;

    setState(() {
      _currentDailyIntake = todayData?.totalAmount ?? 0;
      _weeklyIntake = weeklyData;
    });
  }

  Future<void> _handleAddWater(int amount) async {
    await _waterService.addWaterIntake(amount);
    await _loadAllData();
  }

  @override
  Widget build(BuildContext context) {
    final bool shouldShowAchievementOverlay = _currentDailyIntake >= _dailyWaterGoal;

    return Scaffold(
      body: Stack(
        children: [
          WaterIntake(
            onAmountChanged: _handleAddWater,
            currentTotalAmount: _currentDailyIntake,
            dailyWaterGoal: _dailyWaterGoal,
          ),

          SizedBox(height: 20),

           TimeDisplay(),

          Padding(
            padding: const EdgeInsets.only(top: 440), // 위쪽 공간 확보
            child: SizedBox(
              height: 200,
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: WaterGraph(
                  weeklyIntake: _weeklyIntake,
                  maxY: _dailyWaterGoal.toDouble(),
                ),
              ),
            ),
          ),

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