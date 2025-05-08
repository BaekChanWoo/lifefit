import 'package:flutter/material.dart';
import 'package:lifefit/component/yrin_water/achievement.dart';
import 'package:lifefit/component/yrin_water/time_display.dart';
import 'package:lifefit/component/yrin_water/water_intake.dart';
import 'package:lifefit/component/yrin_water/water_graph.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WaterModel {
  final String? userId; // userId를 nullable.
  final int amount;
  final DateTime date;

  WaterModel({
    this.userId,
    required this.amount,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'amount': amount,
      'date': date.toIso8601String(),
    };
  }
}

class WaterHome extends StatefulWidget {
  const WaterHome({super.key});

  @override
  State<WaterHome> createState() => _WaterHomeState();
}

class _WaterHomeState extends State<WaterHome> {
  int waterAmount = 0;
  Map<int, double> weeklyIntake = {
    0: 0, 1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0,
  };
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // final FirebaseWaterService _firebaseWaterService = FirebaseWaterService();
  late DateTime dateOfNow;

  @override
  void initState() {
    super.initState();
    dateOfNow = DateTime.now();
    _loadWeeklyIntake();
    _loadTodayIntake();
  }

  Future<void> _loadTodayIntake() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day, 0, 0, 0);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    final snapshot = await _firestore
        .collection('water')
        .where('date', isGreaterThanOrEqualTo: startOfDay.toIso8601String())
        .where('date', isLessThanOrEqualTo: endOfDay.toIso8601String())
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
  }

  Future<void> _loadWeeklyIntake() async {
    final now = DateTime.now();
    final firstDayOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final lastDayOfWeek = now.add(Duration(days: DateTime.daysPerWeek - now.weekday));

    weeklyIntake.forEach((key, value) {
      weeklyIntake[key] = 0;
    });

    final snapshot = await _firestore
        .collection('water')
        .where('date', isGreaterThanOrEqualTo: firstDayOfWeek.toIso8601String().split('T')[0])
        .where('date', isLessThanOrEqualTo: lastDayOfWeek.toIso8601String().split('T')[0])
        .get();

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final date = DateTime.parse(data['date'] as String);
      final intakeAmount = (data['amount'] as num).toDouble();
      final dayOfWeek = date.weekday - 1;
      if (weeklyIntake.containsKey(dayOfWeek)) {
        weeklyIntake[dayOfWeek] = (weeklyIntake[dayOfWeek] ?? 0) + intakeAmount;
      }
    }
    setState(() {});
  }

  void handleWaterAmountChanged(int newAmount) async {
    setState(() {
      waterAmount = newAmount;
    });
    final now = DateTime.now();
    await _firestore.collection('water').add({
      'amount': newAmount - (newAmount - waterAmount),
      'date': now.toIso8601String(),
    });
    await _loadWeeklyIntake();
    await _loadTodayIntake();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          WaterIntake(
            onAmountChanged: handleWaterAmountChanged,
          ),
          const TimeDisplay(),
          const SizedBox(width: 20),
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            height: 188,
            child: WaterGraph(weeklyIntake: weeklyIntake),
          ),
          Achievement(waterAmount: waterAmount), //달성 위젯
        ],
      ),
    );
  }
}