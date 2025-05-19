import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lifefit/component/pedometer/step_progress_bar.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DailyChallenge extends StatefulWidget {
  const DailyChallenge({super.key});

  @override
  State<DailyChallenge> createState() => _DailyChallengeState();
}

class _DailyChallengeState extends State<DailyChallenge> {
  int _todaySteps = 0;
  int _stepOffset = 0;

  @override
  void initState() {
    super.initState();
    requestPermission();
    loadStepOffset();
    initPedometer();
  }

  //활동 권한 요청
  void requestPermission() async {
    var status = await Permission.activityRecognition.status;
    if (!status.isGranted) {
      await Permission.activityRecognition.request();
    }
  }

  //SharedPreferences에서 offset 불러오기
  void loadStepOffset() async {
    final prefs = await SharedPreferences.getInstance();
    final savedDate = prefs.getString('stepDate');
    final savedOffset = prefs.getInt('stepOffset') ?? 0;

    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month}-${today.day}';

    if (savedDate != todayStr) {
      // 날짜가 다르면 초기화 예정 (값은 pedometer에서 설정)
      prefs.setString('stepDate', todayStr);
    } else {
      setState(() {
        _stepOffset = savedOffset;
      });
    }
  }

  //pedometer 측정
  void initPedometer() {
    Pedometer.stepCountStream.listen(
          (StepCount event) async {
        final currentSteps = event.steps;
        final prefs = await SharedPreferences.getInstance();
        final savedDate = prefs.getString('stepDate');
        final today = DateTime.now();
        final todayStr = '${today.year}-${today.month}-${today.day}';

        // 날짜가 바뀌었거나 offset이 비정상일 경우 새offset 저장
        if (savedDate != todayStr || _stepOffset == 0) {
          await prefs.setString('stepDate', todayStr);
          await prefs.setInt('stepOffset', currentSteps);
          setState(() {
            _stepOffset = currentSteps;
            _todaySteps = 0;
          });
        } else {
          setState(() {
            _todaySteps = currentSteps - _stepOffset;
          });

          saveStepsToFirebase(_todaySteps);
        }
      },
      onError: (error) {
        print('걸음 수 에러: $error');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StepProgressBar(currentSteps: _todaySteps);
  }
}

void saveStepsToFirebase(int todaySteps) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final uid = user.uid;
  final today = DateTime.now();
  final todayStr =
      '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

  final docRef = FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('steps')
      .doc(todayStr);

  await docRef.set({
    'steps': todaySteps,
    'date': Timestamp.fromDate(today),
    'updatedAt': FieldValue.serverTimestamp(),
  });
}

