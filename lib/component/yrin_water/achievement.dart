import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lifefit/component/yrin_water/water_service.dart';

//
class Achievement extends StatefulWidget {
  final int waterAmount;
  final int dailyWaterGoal;

  const Achievement({
    super.key,
    required this.waterAmount,
    required this.dailyWaterGoal,
  });

  @override
  State<Achievement> createState() => _AchievementState();
}

class _AchievementState extends State<Achievement> {
  bool _isVisible = false;
  final _service = WaterService();
  String? _userId;

  @override
  void initState() {
    super.initState();
    _initCheck();
  }

  @override
  void didUpdateWidget(covariant Achievement oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.waterAmount >= widget.dailyWaterGoal &&
        oldWidget.waterAmount < oldWidget.dailyWaterGoal) {
      _checkAchievementFromFirebase();
    }
  }

  Future<void> _initCheck() async {
    _userId = FirebaseAuth.instance.currentUser?.uid;
    if (_userId != null) {
      await _checkAchievementFromFirebase();
    }
  }

  Future<void> _checkAchievementFromFirebase() async {
    if (_userId == null) return;

    final hasShown = await _service.hasShownAchievementToday(_userId!);

    if (!hasShown && widget.waterAmount >= widget.dailyWaterGoal) {
      setState(() {
        _isVisible = true;
      });
      await _service.markAchievementAsShown(_userId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () {
        setState(() {
          _isVisible = false;
        });
      },
      child: Stack(
        children: [
          Container(color: Colors.black.withAlpha(140)),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/img/happy_face.png', width: 150, height: 110),
                const SizedBox(height: 20),
                const Text(
                  '하루 물 섭취량을 달성했어요!',
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'padauk',
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}