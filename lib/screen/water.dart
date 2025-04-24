import 'package:flutter/material.dart';
import 'package:lifefit/component/yrin_water/achievement.dart';
import 'package:lifefit/component/yrin_water/time_display.dart';
import 'package:lifefit/component/yrin_water/water_intake.dart';
import 'package:lifefit/component/yrin_water/water_graph.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class WaterHome extends StatefulWidget {
  const WaterHome({super.key});

  @override
  State<WaterHome> createState() => _WaterHomeState();
}

class _WaterHomeState extends State<WaterHome> {
  int waterAmount = 0;
  Map<int, double> weeklyIntake = { // 요일별 섭취량 저장 (0: 월, 1: 화, ..., 6: 일)
    0: 0,
    1: 0,
    2: 0,
    3: 0,
    4: 0,
    5: 0,
    6: 0,
  };

  @override
  void initState() {
    super.initState();
    _loadWeeklyIntake();
  }

  Future<void> _loadWeeklyIntake() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final firstDayOfWeek = now.subtract(Duration(days: now.weekday - 1));
    for (int i = 0; i < 7; i++) {
      final day = firstDayOfWeek.add(Duration(days: i));
      final formattedDate = DateFormat('yyyy-MM-dd').format(day);
      weeklyIntake[i] = prefs.getDouble('waterIntake_$formattedDate') ?? 0;
    }
    setState(() {}); // UI 업데이트
  }

  void handleWaterAmountChanged(int newAmount) async {
    setState(() {
      waterAmount = newAmount;
    });
    final now = DateTime.now();
    final formattedDate = DateFormat('yyyy-MM-dd').format(now);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('waterIntake_$formattedDate', newAmount.toDouble());
    await _loadWeeklyIntake(); // 데이터 다시 로드하여 그래프 업데이트
  }

  @override
  Widget build(BuildContext context) {

    return
      Scaffold(
        body: Stack(
          children: [
            WaterIntake(
              initialWaterAmount: waterAmount,
              onAmountChanged: handleWaterAmountChanged,
            ),

            //현재 시간
            TimeDisplay(),

            SizedBox(width: 20,),

            Positioned(       //물 그래프(water_graph) 위치
              bottom: 30,
              left: 20,
              right: 20,
              height: 188,
              child: WaterGraph(weeklyIntake: weeklyIntake),
            ),
            Achievement(waterAmount: waterAmount),    //달성 위젯
          ],
        ),
    );
  }
}
