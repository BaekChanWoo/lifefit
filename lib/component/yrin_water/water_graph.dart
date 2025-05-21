import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lifefit/const/colors.dart';
import 'package:lifefit/component/yrin_water/water_service.dart';
import 'package:lifefit/model/water_daily_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer';


const Color veryPaleBeige = Color(0xFFF5F5DC);

class WaterGraphScreen extends StatefulWidget {
  const WaterGraphScreen({super.key});

  @override
  State<WaterGraphScreen> createState() => _WaterGraphScreenState();
}

class _WaterGraphScreenState extends State<WaterGraphScreen> {
  // 요일별 섭취량 저장
  Map<int, double> weeklyIntake = {
    0: 0, 1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0,
  };

  final FirebaseWaterService _waterService = FirebaseWaterService();
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    // 사용자 ID 초기화, 데이터 로드
    _initializeUserIdAndLoadData();
  }


  Future<void> _initializeUserIdAndLoadData() async {
    _currentUserId = FirebaseAuth.instance.currentUser?.uid;

    if (_currentUserId != null) {
      // 사용자 ID가 있는 경우만 데이터 로드
      await _loadWeeklyIntake();
    } else {
      log('사용자가 로그인되어 있지 않아 물 섭취 기록을 불러올 수 없습니다.',
          name: 'WaterGraphScreen.Auth',
          level: 900); // 경고성 메시지
      setState(() {
        weeklyIntake.updateAll((key, value) => 0.0); // 그래프 데이터 초기화
      });
    }
  }

  // 주간 물 섭취량 데이터
  Future<void> _loadWeeklyIntake() async {
    if (_currentUserId == null) {
      log('loadWeeklyIntake: 사용자 ID가 null이어서 데이터를 로드할 수 없습니다.',
          name: 'WaterGraphScreen.DataLoad',
          level: 900);
      return;
    }

    weeklyIntake.updateAll((key, value) => 0.0);

    final now = DateTime.now();
    final firstDayOfWeek = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    final lastDayOfWeek = DateTime(now.year, now.month, now.day)
        .add(Duration(days: DateTime.daysPerWeek - now.weekday));

    List<DailyIntake> dailyIntakes = await _waterService.getDailyIntakeForPeriod(
      _currentUserId!,
      firstDayOfWeek,
      lastDayOfWeek,
    );

    for (final dailyIntake in dailyIntakes) {
      final date = dailyIntake.date;
      final intakeAmount = dailyIntake.totalAmount.toDouble();
      final dayOfWeek = date.weekday - 1;

      if (weeklyIntake.containsKey(dayOfWeek)) {
        weeklyIntake[dayOfWeek] = (weeklyIntake[dayOfWeek] ?? 0.0) + intakeAmount;
      }
    }
    setState(() {});
  }

  void addWater(int amount) async {
    if (_currentUserId == null) {
      log('addWater: 사용자 ID가 null이어서 물 섭취 기록을 추가할 수 없습니다.',
          name: 'WaterGraphScreen.AddWater',
          level: 900);
      return;
    }
    final now = DateTime.now();
    await _waterService.addWaterIntake(_currentUserId!, amount, now);
    await _loadWeeklyIntake(); // 데이터 추가 후 그래프 다시 로드
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
            toY: entry.value > 2000 ? 2000 : entry.value,
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
      width: double.infinity,
      height: double.infinity,// 부모 너비에 맞춤
      decoration: BoxDecoration(
        color: veryPaleBeige,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(16.0),
      child: BarChart(
        BarChartData(
          backgroundColor: veryPaleBeige,
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
        fontWeight: FontWeight.w600,
        fontFamily: 'NanumSquareRoundk',
        color: Colors.black,
      ),
    );
    return SideTitleWidget(meta: meta, child: text);
  }
}