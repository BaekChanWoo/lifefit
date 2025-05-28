import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lifefit/const/colors.dart';
import 'package:lifefit/provider/water_provider.dart';
import 'package:provider/provider.dart';

class WaterGraphScreen extends StatelessWidget {
  const WaterGraphScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WaterProvider>(
      builder: (context, manager, child) {
        return SizedBox(
          height: 180, // 예시 높이
          width: MediaQuery.of(context).size.width * 0.7, // 예시 너비
          child: WaterGraph(
            // WaterIntakeManager에서 관리하는 weeklyIntake 데이터를 전달
            weeklyIntake: manager.weeklyIntake,
            // WaterIntakeManager에서 관리하는 목표치를 기준으로 색상 및 maxY 설정
            barColorBuilder: (intake) {
              if (intake >= manager.dailyWaterGoal) { // 목표치 사용
                return Colors.green;
              } else if (intake >= manager.dailyWaterGoal / 2) { // 목표치의 절반 이상
                return Colors.lightBlue;
              }
              return PRIMARY_COLOR;
            },
            maxY: manager.dailyWaterGoal.toDouble(), // Y축 최대값도 목표치로 설정
            backgroundColor: Colors.white, // 그래프 배경색을 명시적으로 설정
          ),
        );
      },
    );
  }
}

const Color veryPaleBeige = Color(0xFFF5F5DC);

class WaterGraph extends StatelessWidget {
  final Map<int, double> weeklyIntake; // 요일별 섭취량 데이터 (0=월, 6=일)
  final Color Function(double intake)? barColorBuilder; // 바 색상을 동적으로 결정하는 함수
  final Color backgroundColor; // 그래프 배경색
  final bool showWeekdayLabels; // 요일 라벨 표시 여부
  final bool showYAxisLabels; // Y축 라벨 표시 여부
  final double maxY; // Y축 최대값 (추가됨)

  const WaterGraph({
    super.key,
    required this.weeklyIntake,
    this.barColorBuilder,
    this.backgroundColor = Colors.white,
    this.showWeekdayLabels = true,
    this.showYAxisLabels = true,
    this.maxY = 2000.0, // 기본값 설정
  });

  @override
  Widget build(BuildContext context) {
    final barDataList = weeklyIntake.entries.map((entry) {
      // 바 높이를 maxY를 초과하지 않도록 제한합니다.
      final double intake = entry.value > maxY ? maxY : entry.value;
      final Color barColor = barColorBuilder?.call(intake) ?? PRIMARY_COLOR;

      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: intake,
            color: barColor,
            width: 18,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    }).toList();

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(16.0),
      child: BarChart(
        BarChartData(
          backgroundColor: backgroundColor,
          maxY: maxY, // WaterGraphScreen에서 받은 maxY 사용
          minY: 0,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            show: true,
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: showWeekdayLabels,
                getTitlesWidget: _getBottomTitles,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: showYAxisLabels,
                interval: maxY / 4, // Y축 간격을 목표치에 따라 동적으로 설정
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(value.toInt().toString(), style: const TextStyle(fontSize: 10), textAlign: TextAlign.center,);
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
    final text = Text(koreanWeekdays[value.toInt()], style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.black,),);
    return SideTitleWidget(meta: meta, child: text);
  }
}