import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lifefit/model/water_intake_detail.dart';
import 'package:lifefit/model/water_daily_model.dart';
import 'dart:developer';

class FirebaseWaterService {
  final CollectionReference waterCollection =
  FirebaseFirestore.instance.collection('water');

  // 물 섭취 기록 추가
  Future<void> addWaterIntake(String userId, int amount, DateTime intakeTime) async {
    try {
      final dailyDate = DateTime(intakeTime.year, intakeTime.month, intakeTime.day); // 문서 ID용 순수 날짜

      final dateKey = '${dailyDate.year}-${dailyDate.month.toString().padLeft(2, '0')}-${dailyDate.day.toString().padLeft(2, '0')}';
      final docRef = waterCollection.doc(userId).collection('daily_intake').doc(dateKey);
      // ⭐️ WaterIntakeDetail의 intakeTime에 시간 정보가 포함된 intakeTime을 그대로 전달
      final newDetail = WaterIntakeDetail(amount: amount, intakeTime: intakeTime);

      final docSnapshot = await docRef.get();

      if (!docSnapshot.exists) {
        final newDailyIntake = DailyIntake(
          userId: userId,
          date: dailyDate, // DailyIntake 문서의 'date' 필드는 순수 날짜
          totalAmount: amount,
          intakeDetails: [newDetail],
        );
        await docRef.set(newDailyIntake.toJson());
        log('Firebase에 새로운 일별 기록 문서 생성 (userId: $userId, date: $dateKey)', name: 'FirebaseWaterService');
      } else {
        await docRef.update({
          'totalAmount': FieldValue.increment(amount),
          'intakeDetails': FieldValue.arrayUnion([newDetail.toJson()]),
          'date': Timestamp.fromDate(dailyDate),
        });
        log('Firebase에 기존 일별 기록 문서 업데이트 (userId: $userId, date: $dateKey)', name: 'FirebaseWaterService');
      }
      log('Firebase에 물 섭취 기록 추가/업데이트 성공: $amount ml at $intakeTime', name: 'FirebaseWaterService');
    } catch (e) {
      log('Firebase에 물 섭취 기록 추가/업데이트 실패: $e', error: e, name: 'FirebaseWaterService');
    }
  }

  // 특정 날짜의 개별 물 섭취 기록
  Future<List<WaterIntakeDetail>> getWaterIntakeRecordsForDate(String userId, DateTime date) async {
    try {
      final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final docSnapshot = await waterCollection.doc(userId).collection('daily_intake').doc(dateKey).get();

      if (docSnapshot.exists) {
        final dailyIntake = DailyIntake.fromJson(docSnapshot.data() as Map<String, dynamic>);
        log('Firebase에서 특정 날짜 개별 물 섭취 기록 불러오기 성공: ${dailyIntake.intakeDetails.length}개', name: 'FirebaseWaterService');
        return dailyIntake.intakeDetails;
      }
      log('Firebase에서 특정 날짜 개별 물 섭취 기록 없음', name: 'FirebaseWaterService');
      return [];
    } catch (e) {
      log('Firebase에서 특정 날짜 개별 물 섭취 기록 불러오기 실패: $e', error: e, name: 'FirebaseWaterService');
      return [];
    }
  }

  // 현재까지의 총 물 섭취량 불러오기 -서브컬렉션에서 가져오기
  Future<int> getTotalWaterIntakeForToday(String userId) async {
    try {
      final now = DateTime.now();
      final dailyDate = DateTime(now.year, now.month, now.day); // 오늘의 순수 날짜
      final dateKey = '${dailyDate.year}-${dailyDate.month.toString().padLeft(2, '0')}-${dailyDate.day.toString().padLeft(2, '0')}';
      final docSnapshot = await waterCollection.doc(userId).collection('daily_intake').doc(dateKey).get();

      if (docSnapshot.exists) {
        final dailyIntake = DailyIntake.fromJson(docSnapshot.data() as Map<String, dynamic>);
        log('Firebase에서 오늘의 총 섭취량 불러오기 성공: ${dailyIntake.totalAmount} ml', name: 'FirebaseWaterService');
        return dailyIntake.totalAmount;
      }
      log('Firebase에서 오늘의 총 섭취량 기록 없음 (0ml 반환)', name: 'FirebaseWaterService');
      return 0;
    } catch (e) {
      log('Firebase에서 오늘의 총 섭취량 불러오기 실패: $e', error: e, name: 'FirebaseWaterService');
      return 0;
    }
  }

  // 일주일 그래프 보임
  Future<List<DailyIntake>> getDailyIntakeForPeriod(String userId, DateTime startDate, DateTime endDate) async {
    try {
      // startDate와 endDate도 시간 정보를 제거하여 순수한 날짜로 만듭니다.
      final startOnlyDate = DateTime(startDate.year, startDate.month, startDate.day);
      final endOnlyDate = DateTime(endDate.year, endDate.month, endDate.day);

      final startKey = '${startOnlyDate.year}-${startOnlyDate.month.toString().padLeft(2, '0')}-${startOnlyDate.day.toString().padLeft(2, '0')}';
      final endKey = '${endOnlyDate.year}-${endOnlyDate.month.toString().padLeft(2, '0')}-${endOnlyDate.day.toString().padLeft(2, '0')}';

      final QuerySnapshot snapshot = await waterCollection
          .doc(userId)
          .collection('daily_intake')
          .where(FieldPath.documentId, isGreaterThanOrEqualTo: startKey)
          .where(FieldPath.documentId, isLessThanOrEqualTo: endKey)
          .orderBy(FieldPath.documentId)
          .get();

      final dailyIntakes = snapshot.docs.map((doc) => DailyIntake.fromJson({
        ...(doc.data() as Map<String, dynamic>),
        'date': doc.id
      })).toList();
      log('Firebase에서 특정 기간 일별 섭취량 불러오기 성공: ${dailyIntakes.length}개', name: 'FirebaseWaterService');
      return dailyIntakes;
    } catch (e) {
      log('Firebase에서 특정 기간 일별 섭취량 불러오기 실패: $e', error: e, name: 'FirebaseWaterService');
      return [];
    }
  }

  // 매일 자정에 일별 섭취량 0 초기화
  Future<void> resetDailyIntake(String userId, DateTime date) async {
    try {
      final dailyDate = DateTime(date.year, date.month, date.day); // 순수 날짜 사용
      final dateKey = '${dailyDate.year}-${dailyDate.month.toString().padLeft(2, '0')}-${dailyDate.day.toString().padLeft(2, '0')}';
      final docRef = waterCollection.doc(userId).collection('daily_intake').doc(dateKey);

      await docRef.set({
        'userId': userId,
        'date': Timestamp.fromDate(dailyDate), // 순수 날짜를 Timestamp로 저장
        'totalAmount': 0,
        'intakeDetails': [],
      }, SetOptions(merge: true));

      log('Firebase 일별 섭취량 초기화 성공 (userId: $userId, date: $date)', name: 'FirebaseWaterService');
    } catch (e) {
      log('Firebase 일별 섭취량 초기화 실패: $e', error: e, name: 'FirebaseWaterService');
    }
  }
}