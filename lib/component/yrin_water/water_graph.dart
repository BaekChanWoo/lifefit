import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lifefit/const/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

//물 섭취량 변경시 데이터 로드 그래프 (액자)
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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId = 'guest'; // 실제 사용자 ID로 변경 필요

  @override
  void initState() {
    super.initState();
    _loadWeeklyIntake();
  }

  Future<void> _loadWeeklyIntake() async {
    final now = DateTime.now();
    final firstDayOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final lastDayOfWeek = now.add(Duration(days: DateTime.daysPerWeek - now.weekday));

    weeklyIntake.forEach((key, value) {
      weeklyIntake[key] = 0; // 초기화
    });

    final snapshot = await _firestore
        .collection('water')
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: firstDayOfWeek.toIso8601String().split('T')[0])
        .where('date', isLessThanOrEqualTo: lastDayOfWeek.toIso8601String().split('T')[0])
        .get();

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final date = DateTime.parse(data['date'] as String);
      final intakeAmount = (data['amount'] as num).toDouble();
      final dayOfWeek = date.weekday - 1; // 월요일이 0이 되도록 조정
      if (weeklyIntake.containsKey(dayOfWeek)) {
        weeklyIntake[dayOfWeek] = (weeklyIntake[dayOfWeek] ?? 0) + intakeAmount;
      }
    }
    setState(() {});
  }

  void updateIntake(int amount) async {
    final now = DateTime.now();
    await _firestore.collection('water').add({
      'userId': userId,
      'amount': amount,
      'date': now.toIso8601String(),
    });
    await _loadWeeklyIntake(); // 데이터 다시 로드하여 그래프 업데이트
  }



  //물 그래프 틀
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
                width: MediaQuery.of(context).size.width * 0.7,
                child: WaterGraph(weeklyIntake: weeklyIntake),
              ),
            ),
          ),
          // Example button to update intake (for testing)
        ],
      ),
    );
  }
}

//물 막대 변경 (그림)
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