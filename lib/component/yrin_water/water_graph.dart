import 'package:flutter/material.dart';
import 'package:lifefit/component/yrin_water/graph_data.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lifefit/const/colors.dart';

class WaterGraphScreen extends StatelessWidget {
  final List<double> count = [1750, 500, 250, 250, 750, 2000, 250]; // 예시 데이터 //state 수정
  WaterGraphScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:  Column(
        children: [
          const Spacer(),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 100.0),
              child: SizedBox(
                height: 180, // 그래프 높이 축소
                width: MediaQuery.of(context).size.width * 0.3, // 그래프 너비 축소
                child: WaterGraph(count: count),
              ),
            ),
          )
        ],
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

    return Container( //그래프 모양
      width: 300, // 상자 넓이 설정
      height: 250, // 상자 높이 설정
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BarChart(
          BarChartData(
            backgroundColor: Colors.white,
            maxY: 2000,
            minY: 0,
            gridData: FlGridData(show: false),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              show: true,
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: true, getTitlesWidget: _getBottomTitles,
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 250,
                  reservedSize: 80,// Y축 간격 설정
                  getTitlesWidget: (value, meta) {
                    return Text(
                        value.toInt().toString(), textAlign: TextAlign.center);
                  },
                ),
              ),
            ),
            barGroups: barData
                .map(
                  (data) =>
                  BarChartGroupData(
                    x: data.x,
                    barRods: [
                      BarChartRodData(
                        toY: data.y,
                        color: PRIMARY_COLOR,
                        width: 18,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                    ],
                  ),
            )
                .toList(),
          ),
        ),
      ),
    );
  }
  //요일
  static Widget _getBottomTitles(double value, TitleMeta meta) {
    const koreanWeekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final text = Text(koreanWeekdays[value.toInt()],
      style: TextStyle(
        fontSize: 10, // 폰트 크기 설정
        fontWeight: FontWeight.bold, // 폰트 굵기 설정
        fontFamily: 'padauk', // 폰트 종류 설정 (예: Roboto)
        color: Colors.black, // 폰트 색상 설정
      ),
    );


    if (meta.axisSide != null) {  //유지보수 위해 수정 필요
      return SideTitleWidget(meta: meta, child: text);
    } else {
      //  meta.axisSide가 null인 경우 처리
      return const SizedBox.shrink(); // 빈 SizedBox 반환 또는 다른 위젯 반환
    }
  }
}