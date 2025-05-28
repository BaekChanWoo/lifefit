import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lifefit/model/water_intake_detail.dart';
import 'package:lifefit/model/water_daily_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WaterService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 물 섭취 추가
  Future<void> addWaterIntake(int amount) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final now = DateTime.now();
    final dailyDate = DateTime(now.year, now.month, now.day, 0, 0, 0);

    final intakeDetail = WaterIntakeDetail(amount: amount, intakeTime: now);

    final query = await _firestore
        .collection('water')
        .where('userId', isEqualTo: userId)
        .where('date', isEqualTo: Timestamp.fromDate(dailyDate))
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      final docRef = query.docs.first.reference;
      final docData = query.docs.first.data();

      final List<dynamic> detailsList = docData['intakeDetails'] ?? [];
      detailsList.add(intakeDetail.toJson());

      final int currentTotal = (docData['totalAmount'] ?? 0) as int;
      final int newTotal = currentTotal + amount;

      await docRef.update({
        'intakeDetails': detailsList,
        'totalAmount': newTotal,
      });
    } else {
      await _firestore.collection('water').add({
        'userId': userId,
        'date': Timestamp.fromDate(dailyDate),
        'totalAmount': amount,
        'intakeDetails': [intakeDetail.toJson()],
        'isAchievementShown': false, // 생성 시 초기 상태 설정
      });
    }
  }

  // 오늘 섭취 기록 가져오기
  Future<DailyIntake?> getTodayIntake() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return null;

    final now = DateTime.now();
    final dailyDate = DateTime(now.year, now.month, now.day, 0, 0, 0);

    final query = await _firestore
        .collection('water')
        .where('userId', isEqualTo: userId)
        .where('date', isEqualTo: Timestamp.fromDate(dailyDate))
        .limit(1)
        .get();

    if (query.docs.isEmpty) return null;

    return DailyIntake.fromJson(query.docs.first.data());
  }

  // 오늘 총 섭취량만 가져오기
  Future<int> getTotalAmountForToday() async {
    final intake = await getTodayIntake();
    return intake?.totalAmount ?? 0;
  }

  // 오늘 달성 오버레이 확인
  Future<bool> hasShownAchievementToday(String userId) async {
    final now = DateTime.now();
    final dailyDate = DateTime(now.year, now.month, now.day, 0, 0, 0);

    final query = await _firestore
        .collection('water')
        .where('userId', isEqualTo: userId)
        .where('date', isEqualTo: Timestamp.fromDate(dailyDate))
        .limit(1)
        .get();

    if (query.docs.isEmpty) return false;

    final data = query.docs.first.data();
    return data['isAchievementShown'] == true;
  }

  // 오늘 오버레이를 보여줬다고 표시
  Future<void> markAchievementAsShown(String userId) async {
    final now = DateTime.now();
    final dailyDate = DateTime(now.year, now.month, now.day, 0, 0, 0);

    final query = await _firestore
        .collection('water')
        .where('userId', isEqualTo: userId)
        .where('date', isEqualTo: Timestamp.fromDate(dailyDate))
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      await query.docs.first.reference.update({
        'isAchievementShown': true,
      });
    }
  }

  // 최근 7일간의 물 섭취량 Map
  Future<Map<int, double>> getWeeklyIntake() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return {};

    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 6));
    final endDate = DateTime(now.year, now.month, now.day);

    // 최근 7일간 날짜 리스트 생성
    final days = List.generate(7, (index) => startDate.add(Duration(days: index)));

    final querySnapshot = await _firestore
        .collection('water')
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .get();


    Map<int, double> intakeMap = { for (var d in days) d.day : 0.0 };

    for (var doc in querySnapshot.docs) {
      final data = doc.data();
      final timestamp = data['date'] as Timestamp;
      final date = timestamp.toDate();
      final amount = (data['totalAmount'] ?? 0).toDouble();

      intakeMap[date.day] = amount;
    }

    return intakeMap;
  }
}
