import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lifefit/model/water_intake_detail.dart';
import 'package:lifefit/model/water_daily_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

//
class WaterService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 한국 기준 0시의 UTC 시간 변환
  DateTime getKoreaMidnightUtc(DateTime dateTime) {
    final koreaTime = dateTime.toUtc().add(const Duration(hours: 9));
    final koreaMidnight = DateTime(
        koreaTime.year, koreaTime.month, koreaTime.day);
    final utcMidnight = koreaMidnight.subtract(const Duration(hours: 9));
    return utcMidnight;
  }

  // 물 섭취 추가
  Future<void> addWaterIntake(int amount) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final now = DateTime.now();
    final dailyDateUtc = getKoreaMidnightUtc(now);

    final intakeDetail = WaterIntakeDetail(amount: amount, intakeTime: now);

    final query = await _firestore
        .collection('water')
        .where('userId', isEqualTo: userId)
        .where('date', isEqualTo: Timestamp.fromDate(dailyDateUtc))
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      final docRef = query.docs.first.reference;
      final docData = query.docs.first.data();

      final List<dynamic> detailsList = List.from(
          docData['intakeDetails'] ?? []);
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
        'date': Timestamp.fromDate(dailyDateUtc),
        'totalAmount': amount,
        'intakeDetails': [intakeDetail.toJson()],
        'isAchievementShown': false,
      });
    }
  }

  // 오늘 섭취 기록 가져오기
  Future<DailyIntake?> getTodayIntake() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return null;

    final now = DateTime.now();
    final dailyDateUtc = getKoreaMidnightUtc(now);

    final query = await _firestore
        .collection('water')
        .where('userId', isEqualTo: userId)
        .where('date', isEqualTo: Timestamp.fromDate(dailyDateUtc))
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
    final dailyDateUtc = getKoreaMidnightUtc(now);

    final query = await _firestore
        .collection('water')
        .where('userId', isEqualTo: userId)
        .where('date', isEqualTo: Timestamp.fromDate(dailyDateUtc))
        .limit(1)
        .get();

    if (query.docs.isEmpty) return false;

    final data = query.docs.first.data();
    return data['isAchievementShown'] == true;
  }

  // 오늘 오버레이를 보여줬다고 표시
  Future<void> markAchievementAsShown(String userId) async {
    final now = DateTime.now();
    final dailyDateUtc = getKoreaMidnightUtc(now);

    final query = await _firestore
        .collection('water')
        .where('userId', isEqualTo: userId)
        .where('date', isEqualTo: Timestamp.fromDate(dailyDateUtc))
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

    // 현재 시간 한국 시간 변환
    final koreaNow = now.toUtc().add(const Duration(hours: 9));

    // 한국 시간 기준 이번 주 월요일 0시 계산
    final weekday = koreaNow.weekday;
    final mondayKorea = DateTime(koreaNow.year, koreaNow.month, koreaNow.day)
        .subtract(Duration(days: weekday - 1));

    // 한국 날짜 리스트
    final List<DateTime> koreaDates = List.generate(7, (index) {
      return mondayKorea.add(Duration(days: index));
    });

    // 각 날짜를 UTC 기준으로 바꿔서 Firestore의 date 키와 일치시키기
    final Map<DateTime, int> dateIndexMap = {
      for (int i = 0; i < koreaDates.length; i++)
        getKoreaMidnightUtc(koreaDates[i]): i,
    };

    //  초기값 설정: 월~수는 고정값, 목~일은 0
    Map<int, double> intakeMap = {
      0: 500.0,   // 월요일
      1: 1000.0,  // 화요일
      2: 2000.0,  // 수요일
      3: 0.0,     // 목요일 → Firestore에서 덮어씌움
      4: 0.0,     // 금요일
      5: 0.0,     // 토요일
      6: 0.0,     // 일요일
    };

    // 쿼리: 이번 주 월요일 0시 ~ 일요일 0시
    final startDateUtc = getKoreaMidnightUtc(koreaDates.first);
    final endDateUtc = getKoreaMidnightUtc(koreaDates.last);

    final querySnapshot = await _firestore
        .collection('water')
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDateUtc))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDateUtc))
        .get();

    for (var doc in querySnapshot.docs) {
      final data = doc.data();
      final timestamp = data['date'] as Timestamp;
      final docDateUtc = timestamp.toDate();

      final index = dateIndexMap[docDateUtc];
      if (index != null && index == 3) {
        final amount = (data['totalAmount'] ?? 0).toDouble();
        intakeMap[index] = amount;
      }
    }

    return intakeMap;
  }
}