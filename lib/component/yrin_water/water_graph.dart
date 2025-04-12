import 'package:flutter/material.dart';
import 'package:lifefit/component/yrin_water/graph_data.dart';
import 'package:fl_chart/fl_chart.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: WaterGraphScreen(), // WaterGraphScreen을 홈 화면으로 설정
    );
  }
}

class WaterGraphScreen extends StatelessWidget {
  final List<double> count = [1750, 500, 250, 250, 750, 2000, 250]; // 예시 데이터

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          height: 300, // 그래프 높이 조절
          width: MediaQuery.of(context).size.width * 0.9, // 그래프 너비 조절
          child: WaterGraph(count: count),
        ),
      ),
    );
  }
}

class WaterGraph extends StatelessWidget {
  final List<double> count;

  const WaterGraph({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    // ... (WaterGraph 위젯 코드)
    final barData = BarData(
      mon: count[0],
      tue: count[1],
      wed: count[2],
      thu: count[3],
      fri: count[4],
      sat: count[5],
      sun: count[6],
    ).barData;

    return BarChart(
      BarChartData(
        maxY: 2000,
        minY: 0,
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData:  FlTitlesData(
          show: true,
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: _getBottomTitles,
            ),
          ),
        ),
        barGroups: barData
            .map(
              (data) => BarChartGroupData(
            x: data.x,
            barRods: [
              BarChartRodData(
                toY: data.y,
                color: Colors.grey[800],
                width: 14,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
              ),
            ],
          ),
        )
            .toList(),
      ),
    );
  }

  static Widget _getBottomTitles(double value, TitleMeta meta) {
    const koreanWeekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final text = Text(koreanWeekdays[value.toInt()]);

    if (meta != null && meta.side!= null) {
      return SideTitleWidget(side: meta.side, child: text);
    } else {
      return const SizedBox.shrink();
    }
  }
}
