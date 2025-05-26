import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer';
import 'package:lifefit/model/water_daily_model.dart';


class WaterBox extends StatefulWidget {
  final int dailyTarget; // 일일 목표량 (예: 2000ml)

  const WaterBox({super.key, this.dailyTarget = 2000});

  @override
  State<WaterBox> createState() => _WaterBoxState();
}

class _WaterBoxState extends State<WaterBox> {
  Stream<int> _waterAmountStream = const Stream.empty();
  String? _userId;

  @override
  void initState() {
    super.initState();
    _userId = FirebaseAuth.instance.currentUser?.uid;
    _initializeStream();
  }

  void _initializeStream() {
    if (_userId != null) {
      _waterAmountStream = _getTodayWaterIntakeStream(_userId!);
    } else {
      log('User not logged in, cannot fetch water intake stream.',
          name: 'WaterProgressChart');
      _waterAmountStream = Stream.value(0); // 사용자 없을 시 기본값 스트림
    }
  }

  Stream<int> _getTodayWaterIntakeStream(String userId) {
    final now = DateTime.now();
    final dateKey = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now
        .day.toString().padLeft(2, '0')}';

    return FirebaseFirestore.instance
        .collection('water')
        .doc(userId)
        .collection('daily_intake')
        .doc(dateKey)
        .snapshots() // ⭐️ 이 문서의 실시간 변화를 감지
        .map((docSnapshot) {
      if (docSnapshot.exists && docSnapshot.data() != null) {
        try {
          final dailyIntake = DailyIntake.fromJson(
              docSnapshot.data() as Map<String, dynamic>);
          log('Firebase에서 오늘의 총 섭취량 실시간 업데이트: ${dailyIntake.totalAmount} ml',
              name: 'WaterProgressChart.Stream');
          return dailyIntake.totalAmount;
        } catch (e) {
          log('DailyIntake 파싱 오류: $e', error: e,
              name: 'WaterProgressChart.Stream');
          return 0;
        }
      }
      log('Firebase에서 오늘의 총 섭취량 기록 없음 (0ml 반환)',
          name: 'WaterProgressChart.Stream');
      return 0;
    })
        .handleError((e) {
      log('Error fetching water intake stream: $e', error: e,
          name: 'WaterProgressChart.Stream');
      return 0;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 12.0, top: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "물",
                style: TextStyle(
                  fontSize: 13.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(Icons.water_drop,
                color: Colors.blue,
                size: 20.0,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: StreamBuilder<int>(
            stream: _waterAmountStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(
                    color: Colors.blueAccent, strokeWidth: 2));
              }
              if (snapshot.hasError) {
                return Center(child: Text('오류: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red, fontSize: 12)));
              }
              final currentAmount = snapshot.data ?? 0;
              return _buildBarChart(currentAmount);
            },
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(right: 12.0, bottom: 8.0),
          child: Align(
            alignment: Alignment.centerRight,
            child: StreamBuilder<int>(
              stream: _waterAmountStream,
              builder: (context, snapshot) {
                final currentAmount = snapshot.data ?? 0;
                return Text(
                  '$currentAmount / ${widget.dailyTarget} mL',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBarChart(int currentAmount) {
    final progress = (currentAmount / widget.dailyTarget).clamp(0.0, 1.0);
    final double chartMinY = -0.1;
    final double chartMaxY = 1.1;

    return RotatedBox(
      quarterTurns: -1,
      child: BarChart(
        BarChartData(
          barTouchData: BarTouchData(enabled: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false),
          alignment: BarChartAlignment.start,
          maxY: chartMaxY,
          minY: chartMinY,
          barGroups: [
            BarChartGroupData(
              x: 0,
              barRods: [
                BarChartRodData(
                  toY: progress,
                  width: 24,
                  borderRadius: BorderRadius.circular(4),
                  rodStackItems: [],
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.blue.shade200,
                      Colors.blue.shade800,
                    ],
                  ),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: 1.0,
                    color: Colors.blue.shade50,
                  ),
                ),
              ],
            ),
          ],
        ),
        swapAnimationDuration: const Duration(milliseconds: 500),
        swapAnimationCurve: Curves.easeOutCubic,
      ),
    );
  }
}