import 'package:flutter/material.dart';
import 'package:lifefit/component/yrin_water/achievement.dart';
import 'package:lifefit/component/yrin_water/time_display.dart';
import 'package:lifefit/component/yrin_water/water_intake.dart';

void main() { // WaterHome 호출
  runApp(const WaterHome());
}

class WaterHome extends StatefulWidget {
  const WaterHome({super.key});

  @override
  _WaterHomeState createState() => _WaterHomeState();
}

class _WaterHomeState extends State<WaterHome> {
  int waterAmount = 0;

  void handleWaterAmountChanged(int newAmount) {
    setState(() {
      waterAmount = newAmount;
    });
  }
//물 섭취 UI 구성 Scaffold 위젯
  @override
  Widget build(BuildContext context) {
    return MaterialApp(  //MaterialApp
      home: Scaffold(
        body: Stack(
          children: [
            WaterIntake(
              waterAmount: waterAmount,
              onAmountChanged: handleWaterAmountChanged,
            ),

            //현재 시간
            TimeDisplay(),
            Achievement(waterAmount: waterAmount),
          ],
        ),
      ),
    );
  }
}