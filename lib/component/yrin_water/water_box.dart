import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lifefit/component/yrin_water/water_service.dart';

class WaterBox extends StatefulWidget {
  final VoidCallback onContainerTapped;

  const WaterBox({super.key, required this.onContainerTapped});

  @override
  State<WaterBox> createState() => WaterBoxState();
}

class WaterBoxState extends State<WaterBox> {
  Map<int, double> weeklyIntake = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadWeeklyData();
  }

  Future<void> loadWeeklyData() async {
    setState(() => isLoading = true);
    final data = await WaterService().getWeeklyIntake();
    setState(() {
      weeklyIntake = data;
      isLoading = false;
    });
  }

  // 외부 호출
  void refreshData() {
    loadWeeklyData();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onContainerTapped();
        Navigator.of(context).pushNamed('water').then((_) {
          refreshData(); // 물 페이지에서 돌아왔을 때 새로고침/
        });
      },
      child: Container(
        height: 200,
        width: MediaQuery.of(context).size.width - 240,
        margin: const EdgeInsets.symmetric(horizontal: 30),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(
            color: Colors.grey,
            width: 1.0,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "물",
                    style: TextStyle(
                      fontSize: 13.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Icon(
                    Icons.water_drop,
                    color: Colors.blue,
                    size: 20.0,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                    : FlChartWaterGraph(
                  weeklyIntake: weeklyIntake,
                  maxY: 2000, // 목표량 설정
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FlChartWaterGraph extends StatelessWidget {
  final Map<int, double> weeklyIntake;
  final double maxY;

  const FlChartWaterGraph({
    super.key,
    required this.weeklyIntake,
    required this.maxY,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white, // 배경 흰색
        borderRadius: BorderRadius.circular(10),
      ),
      child: BarChart(
        BarChartData(
          maxY: maxY,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(show: false),
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(7, (index) {
            final y = weeklyIntake[index] ?? 0;
            return BarChartGroupData(
              x: index,
              barsSpace: 1,
              barRods: [
                // 연한 하늘색 배경
                BarChartRodData(
                  toY: maxY,
                  width: 6,
                  color: const Color(0xFFB3D9FF),
                  borderRadius: BorderRadius.circular(6),
                ),
                // 누적된 값만큼 채우는 진한 파란색
                BarChartRodData(
                  toY: y.clamp(0, maxY),
                  width: 6,
                  color: const Color(0xFF003366),
                  borderRadius: BorderRadius.circular(6),
                ),
              ],
            );
          }),
          alignment: BarChartAlignment.spaceAround,
        ),
      ),
    );
  }
}
