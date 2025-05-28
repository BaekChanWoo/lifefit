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
        height: 145,
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
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFDDEEFF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: BarChart(
        BarChartData(
          maxY: maxY,
          borderData: FlBorderData(show: false),
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const days = ['월', '화', '수', '목', '금', '토', '일'];
                  final index = value.toInt();
                  if (index < 0 || index >= days.length) return const SizedBox.shrink();
                  return SideTitleWidget(
                    meta: meta,
                    child: Text(days[index], style: const TextStyle(fontSize: 10)),
                  );
                },
                reservedSize: 24,
                interval: 1,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 30, interval: maxY / 4),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          barGroups: List.generate(7, (index) {
            final y = weeklyIntake[index] ?? 0;
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: y > maxY ? maxY : y,
                  width: 14,
                  color: const Color(0xFF003366),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(6),
                    topRight: Radius.circular(6),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

