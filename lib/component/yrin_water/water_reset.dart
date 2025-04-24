import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _waterAmountKey = 'waterAmount';

class WaterResetService {
  //앱 시작 시 저장된 물 섭취량 불러 오기
  static Future<int> loadWaterAmount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_waterAmountKey) ?? 0; // 값이 없으면 0 반환
  }

  //물 섭취량 영구 저장
  static Future<void> saveWaterAmount(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_waterAmountKey, amount);
  }

  //앱 시작 시 자정 확인 후 0 리셋 ( 리셋 한번 호출 )
  static Future<void> checkAndResetWaterAmount(
      StateSetter setStateCallback,
      Function(int) onAmountChangedCallback,
      ) async {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day, 0, 0, 0); // 오늘 자정
    if (now.isAfter(midnight)) {
      setStateCallback(() {
        onAmountChangedCallback(0);
      });
      await saveWaterAmount(0); // 초기화 후 저장
    } else {
      // 자정 이전 시 저장된 값 불러 오기
      final savedAmount = await loadWaterAmount();
      setStateCallback(() {
        onAmountChangedCallback(savedAmount);
      });
    }
  }

  //매일 자정 0으로 초기화 설정
  static void scheduleDailyReset(
      StateSetter setStateCallback,
      Function(int) onAmountChangedCallback,
      ) {
    _scheduleReset(setStateCallback, onAmountChangedCallback);
  }

  // 0으로 초기화 후 저장 다음날 초기화 예약 내부 함수
  static void _resetWaterAmountAndReschedule(
      StateSetter setStateCallback,
      Function(int) onAmountChangedCallback,
      ) async {
    setStateCallback(() {
      onAmountChangedCallback(0);
    });
    await saveWaterAmount(0); // 초기화 후 저장
    _scheduleReset(setStateCallback, onAmountChangedCallback); // 다음 날 자정 예약
  }

  // 자정 초기화 스케줄링 내부 함수
  static void _scheduleReset(
      StateSetter setStateCallback,
      Function(int) onAmountChangedCallback,
      ) {
    final now = DateTime.now();
    final nextMidnight = DateTime(now.year, now.month, now.day + 1, 0, 0, 0);
    final initialDelay = nextMidnight.difference(now);

    Future.delayed(initialDelay, () {
      _resetWaterAmountAndReschedule(setStateCallback, onAmountChangedCallback);
    });
  }

  //물 섭취량 증가 후 저장
  static Future<void> incrementWaterAmount(
      int currentAmount,
      int increment,
      Function(int) onAmountChangedCallback,
      ) async {
    final newAmount = currentAmount + increment;
    if (newAmount <= 2000) {
      onAmountChangedCallback(newAmount);
      await saveWaterAmount(newAmount);
    }
  }
}