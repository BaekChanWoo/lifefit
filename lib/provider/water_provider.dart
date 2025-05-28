import 'dart:developer';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


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

// Firebase에서 데이터를 받아올 때 사용할 DailyIntake 모델 (이전에 정의된 클래스라고 가정)
class DailyIntake {
  final DateTime date;
  final int totalAmount;

  DailyIntake({required this.date, required this.totalAmount});
}


// FirebaseWaterService 클래스 (Provider에서 Firestore와 통신하는 역할, 이전에 정의된 클래스라고 가정)
class FirebaseWaterService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<DailyIntake>> getDailyIntakeStreamForPeriod(
      String userId, DateTime startDate, DateTime endDate) {
    return _firestore
        .collection('water')
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .snapshots()
        .map((snapshot) {
      Map<DateTime, int> dailyAmounts = {};

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final Timestamp? timestamp = data['date'] as Timestamp?;
        final int amount = (data['amount'] as num).toInt();

        if (timestamp != null) {
          final DateTime dateOnly = DateTime(timestamp.toDate().year,
              timestamp.toDate().month, timestamp.toDate().day);
          dailyAmounts.update(dateOnly, (value) => value + amount,
              ifAbsent: () => amount);
        }
      }
      return dailyAmounts.entries
          .map((entry) => DailyIntake(date: entry.key, totalAmount: entry.value))
          .toList();
    }).handleError((e) {
      log('Error getting daily intake stream for period: $e',
          name: 'FirebaseWaterService.GetStream', level: 1000);
      return <DailyIntake>[];
    });
  }

  Future<void> addWaterRecord(WaterModel waterModel) async {
    try {
      await _firestore.collection('water').add(waterModel.toJson());
      log('Firestore: Water record added successfully.', name: 'FirebaseWaterService');
    } catch (e) {
      log('Firestore: Error adding water record: $e',
          name: 'FirebaseWaterService', level: 1000);
      rethrow;
    }
  }
}


class WaterProvider with ChangeNotifier {
  // --- 상태 변수들 ---
  int _currentDailyIntake = 0;
  Map<int, double> _weeklyIntake = {
    0: 0, 1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0,
  };
  final int _dailyWaterGoal = 2000;

  // --- Getter 메서드들 ---
  int get currentDailyIntake => _currentDailyIntake;
  Map<int, double> get weeklyIntake => _weeklyIntake;
  int get dailyWaterGoal => _dailyWaterGoal; // <--- 이 getter가 있어서 dailyWaterGoal 오류는 나지 않아야 합니다.

  // --- Firebase 서비스 및 스트림 구독 관리 ---
  final FirebaseWaterService _waterService = FirebaseWaterService();
  String? _currentUserId;
  StreamSubscription<List<DailyIntake>>? _dailyIntakeSubscription;
  StreamSubscription<List<DailyIntake>>? _weeklyIntakeSubscription;

  // --- 생성자 ---
  WaterProvider() {
    log('WaterProvider initialized. Awaiting explicit start command.',
        name: 'WaterProvider.Init');
  }

  // --- 외부에서 호출될 스트림 시작 메서드 ---
  Future<void> startListeningToWaterData() async {
    _currentUserId = FirebaseAuth.instance.currentUser?.uid;

    if (_currentUserId != null) {
      log('User logged in: $_currentUserId. Starting water data streams.',
          name: 'WaterProvider.Start');
      _startListeningToDailyIntakeInternal();
      _startListeningToWeeklyIntakeInternal();
    } else {
      log('User not logged in. Cannot start water data streams.',
          name: 'WaterProvider.Start', level: 900);
      _currentDailyIntake = 0;
      _weeklyIntake.updateAll((key, value) => 0.0);
      notifyListeners();
    }
  }

  // --- 외부에서 호출될 스트림 중지 메서드 ---
  void stopListeningToWaterData() {
    _dailyIntakeSubscription?.cancel();
    _weeklyIntakeSubscription?.cancel();
    _dailyIntakeSubscription = null;
    _weeklyIntakeSubscription = null;
    log('Water data streams stopped and cancelled.',
        name: 'WaterProvider.Stop');

    _currentDailyIntake = 0;
    _weeklyIntake.updateAll((key, value) => 0.0);
    notifyListeners();
  }

  // --- 오늘의 물 섭취량 데이터 스트림 구독 시작 (내부 메서드) ---
  void _startListeningToDailyIntakeInternal() {
    if (_currentUserId == null) return;

    _dailyIntakeSubscription?.cancel();

    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day, 0, 0, 0);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    _dailyIntakeSubscription = _waterService
        .getDailyIntakeStreamForPeriod(_currentUserId!, startOfDay, endOfDay)
        .listen((dailyIntakes) {
      int totalAmount = 0;
      for (final dailyIntake in dailyIntakes) {
        // 오늘의 데이터만 합산하도록 명시적으로 날짜를 비교합니다.
        // Firebase 쿼리 자체가 이미 오늘 데이터를 가져오지만,
        // 혹시 모를 경우를 대비해 더 정확하게 특정 날짜의 데이터를 확인하는 것이 좋습니다.
        if (dailyIntake.date.year == now.year &&
            dailyIntake.date.month == now.month &&
            dailyIntake.date.day == now.day) {
          totalAmount += dailyIntake.totalAmount;
          break; // 오늘의 데이터는 한 번만 처리 (Firebase 쿼리가 일별 합산된 데이터를 주므로)
        }
      }
      if (_currentDailyIntake != totalAmount) {
        _currentDailyIntake = totalAmount;
        log('Current daily intake updated: $_currentDailyIntake ml',
            name: 'WaterProvider.DailyUpdate');
        notifyListeners();
      }
    }, onError: (e) {
      log('Error listening to daily intake stream: $e',
          name: 'WaterProvider.Error', level: 1000);
      if (_currentDailyIntake != 0) {
        _currentDailyIntake = 0;
        notifyListeners();
      }
    });
  }

  // --- 주간 물 섭취량 데이터 스트림 구독 시작 (내부 메서드) ---
  void _startListeningToWeeklyIntakeInternal() {
    if (_currentUserId == null) return;

    _weeklyIntakeSubscription?.cancel();

    final now = DateTime.now();
    final firstDayOfWeek = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
    // 주간 쿼리에서 마지막 날짜를 정확하게 23:59:59로 설정해야 해당 일자의 데이터가 포함됩니다.
    final lastDayOfWeek = DateTime(now.year, now.month, now.day).add(Duration(days: DateTime.daysPerWeek - now.weekday));
    final adjustedLastDayOfWeek = DateTime(lastDayOfWeek.year, lastDayOfWeek.month, lastDayOfWeek.day, 23, 59, 59);


    _weeklyIntakeSubscription = _waterService
        .getDailyIntakeStreamForPeriod(
        _currentUserId!, firstDayOfWeek, adjustedLastDayOfWeek) // 조정된 lastDayOfWeek 사용
        .listen((dailyIntakes) {
      Map<int, double> newWeeklyIntake = {
        0: 0, 1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0,
      };
      for (final dailyIntake in dailyIntakes) {
        final date = dailyIntake.date;
        final intakeAmount = dailyIntake.totalAmount.toDouble();
        final dayOfWeek = date.weekday - 1; // 0: Mon, 6: Sun

        if (newWeeklyIntake.containsKey(dayOfWeek)) {
          newWeeklyIntake[dayOfWeek] =
              (newWeeklyIntake[dayOfWeek] ?? 0.0) + intakeAmount;
        }
      }
      _weeklyIntake = newWeeklyIntake;
      log('Weekly intake data updated: $_weeklyIntake',
          name: 'WaterProvider.WeeklyUpdate');
      notifyListeners();
    }, onError: (e) {
      log('Error listening to weekly intake stream: $e',
          name: 'WaterProvider.Error', level: 1000);
      if (_weeklyIntake.values.any((amount) => amount > 0)) {
        _weeklyIntake.updateAll((key, value) => 0.0);
        notifyListeners();
      }
    });
  }

  // --- 여기부터 addWater 메서드를 추가해야 합니다! ---
  Future<void> addWater(int amountChange) async {
    final now = DateTime.now();
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      log('User not logged in. Cannot add water intake.', name: 'WaterProvider.Auth');
      return;
    }

    // 목표량 _dailyWaterGoal을 초과하지 않도록 제한
    int actualAmountToAdd = amountChange;
    if (_currentDailyIntake + amountChange > _dailyWaterGoal) {
      actualAmountToAdd = _dailyWaterGoal - _currentDailyIntake;
      if (actualAmountToAdd <= 0) { // 이미 목표량을 초과했거나 같으면 더 이상 추가할 수 없음
        log('Water intake already reached or exceeded goal. Cannot add more.', name: 'WaterProvider.AddWater');
        return;
      }
    }

    try {
      final waterData = WaterModel(
        userId: userId,
        date: now,
        amount: actualAmountToAdd, // 제한된 양을 추가
      );
      await _waterService.addWaterRecord(waterData);
      log('Water intake record added: $actualAmountToAdd mL', name: 'WaterProvider.AddWater');
      // Stream을 통해 자동으로 _currentDailyIntake가 업데이트되므로, 여기서 직접 setState/notifyListeners는 필요 없음
    } catch (e) {
      log('Error adding water intake record: $e', name: 'WaterProvider.AddWaterError');
    }
  }
}