import 'package:flutter/material.dart';
import 'package:lifefit/component/yrin_water/water_graph.dart';

class WaterBox extends StatelessWidget {
  final Map<int, double> weeklyIntake; // 외부에서 데이터를 받습니다.
  final double maxIntake; // 외부에서 목표치를 받습니다.

  const WaterBox({
    super.key,
    required this.weeklyIntake, // required로 변경
    required this.maxIntake, // required로 변경
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: WaterGraph(
        weeklyIntake: weeklyIntake, // 받은 데이터 전달
        maxY: maxIntake, // 받은 목표치 전달
        // WaterBox의 배경색을 여기서 설정할 수 있습니다.
        backgroundColor: Colors.transparent, // WaterBox 컨테이너의 배경색이 적용되도록 투명하게 설정
      ),
    );
  }
}



