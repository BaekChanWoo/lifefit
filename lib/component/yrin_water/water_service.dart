import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lifefit/model/water_model.dart'; // 모델 클래스 import

class FirebaseWaterService {
  final CollectionReference waterCollection =
  FirebaseFirestore.instance.collection('water');

  // 새 물 섭취 기록 추가.
  Future<void> addWaterIntake(String userId, int amount, DateTime intakeTime) async {
    try {
      final record = WaterIntakeRecord(userId: userId, amount: amount,);
      await waterCollection.doc(userId).collection('records').add(record.toJson());
      print('Firebase에 물 섭취 기록 저장 성공: ${record.toJson()}');
    } catch (e) {
      print('Firebase에 물 섭취 기록 저장 실패: $e');
    }
  }

  // 특정 날짜의 물 섭취 기록 불러오기
  Future<List<WaterIntakeRecord>> getWaterIntakeRecordsForDate(String userId, DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day, 0, 0, 0);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      final QuerySnapshot snapshot = await waterCollection
          .doc(userId)
          .collection('records')
          .where('intakeTime', isGreaterThanOrEqualTo: startOfDay)
          .where('intakeTime', isLessThanOrEqualTo: endOfDay)
          .orderBy('intakeTime')
          .get();

      return snapshot.docs.map((doc) => WaterIntakeRecord.fromJson(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Firebase에서 특정 날짜 물 섭취 기록 불러오기 실패: $e');
      return [];
    }
  }

  // 일별 총 섭취량 저장 또는 업데이트
  Future<void> saveDailyIntake(String userId, DateTime date, int totalAmount) async {
    try {
      final dailyIntake = DailyIntake(userId: userId, date: date, totalAmount: totalAmount);
      final docId = 'daily_${userId}_${date.toIso8601String().split('T')[0]}';
      await waterCollection.doc(userId).collection('daily_intake').doc(docId).set(dailyIntake.toJson(), SetOptions(merge: true));
      print('Firebase에 일별 섭취량 저장/업데이트 성공: ${dailyIntake.toJson()}');
    } catch (e) {
      print('Firebase에 일별 섭취량 저장/업데이트 실패: $e');
    }
  }

  // 특정 기간의 일별 총 섭취량 불러오기 (그래프 데이터)
  Future<List<DailyIntake>> getDailyIntakeForPeriod(String userId, DateTime startDate, DateTime endDate) async {
    try {
      final QuerySnapshot snapshot = await waterCollection
          .doc(userId)
          .collection('daily_intake')
          .where('date', isGreaterThanOrEqualTo: startDate.toIso8601String().split('T')[0])
          .where('date', isLessThanOrEqualTo: endDate.toIso8601String().split('T')[0])
          .orderBy('date')
          .get();

      return snapshot.docs.map((doc) => DailyIntake.fromJson(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Firebase에서 특정 기간 일별 섭취량 불러오기 실패: $e');
      return [];
    }
  }

  // 매일 자정에 일별 섭취량 초기화 (총 섭취량을 0으로 업데이트)
  Future<void> resetDailyIntake(String userId, DateTime date) async {
    try {
      final docId = 'daily_${userId}_${date.toIso8601String().split('T')[0]}';
      await waterCollection.doc(userId).collection('daily_intake').doc(docId).update({'totalAmount': 0});
      print('Firebase 일별 섭취량 초기화 성공 (userId: $userId, date: $date)');
    } catch (e) {
      print('Firebase 일별 섭취량 초기화 실패: $e');
    }
  }

  // 현재까지의 총 섭취량 불러오기 (오늘 날짜 기준)
  Future<int> getTotalWaterIntakeForToday(String userId) async {
    final now = DateTime.now();
    final records = await getWaterIntakeRecordsForDate(userId, now);
    int total = 0;
    for (var record in records) {
      total += record.amount;
    }
    return total;
  }
}