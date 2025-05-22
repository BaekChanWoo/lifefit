import 'package:flutter/material.dart';
import 'package:lifefit/component/yrin_water/achievement.dart';
import 'package:lifefit/component/yrin_water/time_display.dart';
import 'package:lifefit/component/yrin_water/water_intake.dart';
import 'package:lifefit/component/yrin_water/water_graph.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer';

class WaterModel {
  final String? userId;
  final DateTime date;
  int amount;

  WaterModel({
    required this.userId,
    required this.date,
    required this.amount,
  });

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'amount': amount,
    'date': Timestamp.fromDate(date),
  };
}

class WaterHome extends StatefulWidget {
  const WaterHome({super.key});

  @override
  State<WaterHome> createState() => _WaterHomeState();
}

class _WaterHomeState extends State<WaterHome> {
  int waterAmount = 0; // 오늘의 총 섭취량
  Map<int, double> weeklyIntake = {
    0: 0, 1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, // 월요일(0) ~ 일요일(6)
  };
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late DateTime dateOfNow;
  bool _hasShownAchievement = false;

  @override
  void initState() {
    super.initState();
    dateOfNow = DateTime.now();
    _initializeData(); // 초기화 함수 호출
  }

  // 데이터 로딩을 위한 단일 초기화 함수
  Future<void> _initializeData() async {
    await _loadWeeklyIntake();
    await _loadTodayIntake();
  }

  Future<void> _loadTodayIntake() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day, 0, 0, 0);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
    final String? userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      log('사용자가 로그인되어 있지 않아 오늘의 물 섭취 기록을 불러올 수 없습니다.', name: 'WaterHome.Auth');
      return;
    }

    try {
      final snapshot = await _firestore
          .collection('water')
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .get();

      int totalAmount = 0;
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final intakeAmount = (data['amount'] as num).toInt();
        totalAmount += intakeAmount;
      }
      setState(() {
        waterAmount = totalAmount;
      });
    } catch (e) {
      log('오늘의 물 섭취 기록 로드 중 오류 발생: $e', name: 'WaterHome.LoadToday');
    }
  }

  Future<void> _loadWeeklyIntake() async {
    final now = DateTime.now();
    final firstDayOfWeek = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
    final lastDayOfWeek = DateTime(now.year, now.month, now.day).add(Duration(days: DateTime.daysPerWeek - now.weekday));

    final String? userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      log('사용자가 로그인되어 있지 않아 주간 물 섭취 기록을 불러올 수 없습니다.', name: 'WaterHome.Auth');
      return;
    }

    // weeklyIntake 초기화
    weeklyIntake = {
      0: 0, 1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0,
    };

    try {
      final snapshot = await _firestore
          .collection('water')
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(firstDayOfWeek))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(lastDayOfWeek))
          .get();

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final Timestamp? timestamp = data['date'] as Timestamp?;
        if (timestamp != null) {
          final DateTime date = timestamp.toDate();
          final intakeAmount = (data['amount'] as num).toDouble();
          final dayOfWeek = date.weekday - 1;
          if (weeklyIntake.containsKey(dayOfWeek)) {
            weeklyIntake[dayOfWeek] = (weeklyIntake[dayOfWeek] ?? 0) + intakeAmount;
          }
        }
      }
      log('Weekly Intake Loaded: $weeklyIntake', name: 'WaterHome.WeeklyIntake');
      setState(() {});
    } catch (e) {
      log('주간 물 섭취 기록 로드 중 오류 발생: $e', name: 'WaterHome.LoadWeekly');
    }
  }


  void handleWaterAmountChanged(int amountChange) async {
    final now = DateTime.now();
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      log('사용자가 로그인되어 있지 않아 물 섭취 기록을 추가/업데이트할 수 없습니다.', name: 'WaterHome.Auth');
      return;
    }

    try {
      final waterData = WaterModel(
        userId: userId,
        date: now,
        amount: amountChange,
      ).toJson();

      await _firestore.collection('water').add(waterData);
      log('물 섭취 기록 추가됨: $amountChange mL', name: 'WaterHome.AddWater');

      await _loadTodayIntake();
      await _loadWeeklyIntake();
    } catch (e) {
      log('물 섭취 기록 추가 중 오류 발생: $e', name: 'WaterHome.AddWaterError');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          WaterIntake(
            onAmountChanged: handleWaterAmountChanged,
            initialWaterAmount: waterAmount,
          ),
          const TimeDisplay(),
          const SizedBox(width: 20),
          Positioned(
            bottom: 40,
            left: 28,
            right: 28,
            height: 200,
            child: WaterGraph(weeklyIntake: weeklyIntake),
          ),
          Achievement(
            waterAmount: waterAmount,
            hasShown: _hasShownAchievement,
            onAchievementShown: () {
              setState(() {
                _hasShownAchievement = true;
              });
            },
          ),
        ],
      ),
    );
  }
}