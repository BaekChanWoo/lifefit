import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lifefit/const/colors.dart';
import 'package:lifefit/component/yrin_water/water_service.dart';

//
class WaterGraphWithFirebase extends StatefulWidget {
  final double maxY;
  final Color backgroundColor;
  final bool showWeekdayLabels;
  final bool showYAxisLabels;

  const WaterGraphWithFirebase({
    super.key,
    this.maxY = 2000,
    this.backgroundColor = Colors.white,
    this.showWeekdayLabels = true,
    this.showYAxisLabels = true,
  });

  @override
  State<WaterGraphWithFirebase> createState() => _WaterGraphWithFirebaseState();
}

class _WaterGraphWithFirebaseState extends State<WaterGraphWithFirebase> {
  Map<int, double> weeklyIntake = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadWeeklyIntake();
  }

  Future<void> loadWeeklyIntake() async {
    final data = await WaterService().getWeeklyIntake();
    setState(() {
      weeklyIntake = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return WaterGraph(
      weeklyIntake: weeklyIntake,
      maxY: widget.maxY,
      backgroundColor: widget.backgroundColor,
      showWeekdayLabels: widget.showWeekdayLabels,
      showYAxisLabels: widget.showYAxisLabels,
      barColorBuilder: (intake) {
        if (intake >= widget.maxY) {
          return Colors.green;
        } else if (intake >= widget.maxY / 2) {
          return Colors.lightBlue;
        }
        return PRIMARY_COLOR;
      },
    );
  }
}

class WaterGraph extends StatelessWidget {
  final Map<int, double> weeklyIntake;
  final Color Function(double intake)? barColorBuilder;
  final Color backgroundColor;
  final bool showWeekdayLabels;
  final bool showYAxisLabels;
  final double maxY;

  const WaterGraph({
    super.key,
    required this.weeklyIntake,
    this.barColorBuilder,
    this.backgroundColor = Colors.white,
    this.showWeekdayLabels = true,
    this.showYAxisLabels = true,
    this.maxY = 2000.0,
  });

  @override
  Widget build(BuildContext context) {
    final barDataList = weeklyIntake.entries.map((entry) {
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
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(16.0),
      child: BarChart(
        BarChartData(
          backgroundColor: backgroundColor,
          maxY: maxY,
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
                interval: maxY / 4,
                reservedSize: 40,
                getTitlesWidget: (value, meta) => Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 10),
                  textAlign: TextAlign.center,
                ),
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
    return SideTitleWidget(
      meta: meta,
      child: Text(
        koreanWeekdays[value.toInt()],
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.black),
      ),
    );
  }
}
