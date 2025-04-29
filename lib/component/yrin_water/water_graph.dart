import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lifefit/const/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class WaterGraphScreen extends StatefulWidget {
  const WaterGraphScreen({super.key});

  @override
  State<WaterGraphScreen> createState() => _WaterGraphScreenState();
}

class _WaterGraphScreenState extends State<WaterGraphScreen> {
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
    for (int i = 0; i < 7; i++) {
      final day = now.subtract(Duration(days: now.weekday - 1 - i)); // 해당 주의 각 요일
      final formattedDate = DateFormat('yyyy-MM-dd').format(day);
      weeklyIntake[i] = prefs.getDouble('waterIntake_$formattedDate') ?? 0;
    }
    setState(() {}); // UI 업데이트
  }

  // 물 섭취량 업데이트 및 저장 (예시 함수 - 실제 로직에 맞춰 수정)
  void updateIntake(int amount) async {
    final now = DateTime.now();
    final formattedDate = DateFormat('yyyy-MM-dd').format(now);
    final prefs = await SharedPreferences.getInstance();
    final currentIntake = prefs.getDouble('waterIntake_$formattedDate') ?? 0;
    final newIntake = currentIntake + amount;
    await prefs.setDouble('waterIntake_$formattedDate', newIntake);
    _loadWeeklyIntake(); // 데이터 다시 로드하여 그래프 업데이트
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Spacer(),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 100.0),
              child: SizedBox(
                height: 180,
                width: MediaQuery.of(context).size.width * 0.7, // 그래프 너비 조정
                child: WaterGraph(weeklyIntake: weeklyIntake),
              ),
            ),
          ),
          // Example button to update intake (for testing)
          ElevatedButton(
            onPressed: () => updateIntake(250),
            child: const Text('물 250ml 추가'),
          ),
        ],
      ),
    );
  }
}

class WaterGraph extends StatelessWidget {
  final Map<int, double> weeklyIntake;

  const WaterGraph({super.key, required this.weeklyIntake});

  @override
  Widget build(BuildContext context) {
    final barDataList = weeklyIntake.entries.map((entry) {
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: entry.value,
            color: PRIMARY_COLOR,
            width: 18,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(4),
            ),
          ),
        ],
      );
    }).toList();

    return Container(
      width: double.infinity, // 부모 너비에 맞춤
      height: 250,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(16.0),
      child: BarChart(
        BarChartData(
          backgroundColor: Colors.white,
          maxY: 2000,
          minY: 0,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            show: true,
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: _getBottomTitles,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 250,
                reservedSize: 80,
                getTitlesWidget: (value, meta) {
                  return Text(value.toInt().toString(), textAlign: TextAlign.center);
                },
              ),
            ),
          ),
          barGroups: barDataList,
        ),
      ),
    );
  }

  static Widget _getBottomTitles(double value, TitleMeta meta) {
    const koreanWeekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final text = Text(
      koreanWeekdays[value.toInt()],
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.bold,
        fontFamily: 'padauk',
        color: Colors.black,
      ),
    );
    return SideTitleWidget(meta: meta, child: text);
  }
}