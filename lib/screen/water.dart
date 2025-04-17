import 'package:flutter/material.dart';
import 'package:lifefit/component/yrin_water/achievement.dart';
import 'package:lifefit/component/yrin_water/time_display.dart';
import 'package:lifefit/component/yrin_water/water_intake.dart';
import 'package:lifefit/component/yrin_water/water_graph.dart';

class WaterHome extends StatefulWidget {
  const WaterHome({super.key});

  @override
  State<WaterHome> createState() => _WaterHomeState();
}

class _WaterHomeState extends State<WaterHome> {
  int waterAmount = 0;
  final List<double> count = [1750, 500, 250, 250, 750, 2000, 250];

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
            Positioned(
                bottom: 87,
                left: 20,
                right: 20,
                height: 188,
                child: WaterGraph(count: count)) ,
            Achievement(waterAmount: waterAmount),// 그래프 위젯 추가
          ],
        ),
      ),
    );
  }
}
