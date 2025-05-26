//물 그래프용 일별 총량
import 'package:lifefit/model/water_intake_detail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DailyIntake {
  final String userId;
  final DateTime date; // 순수 날짜 (YYYY-MM-DD)
  final int totalAmount;
  final List<WaterIntakeDetail> intakeDetails;

  DailyIntake({
    required this.userId,
    required this.date,
    required this.totalAmount,
    required this.intakeDetails,
  });

  factory DailyIntake.fromJson(Map<String, dynamic> json) {
    List<dynamic> detailsList = json['intakeDetails'] ?? [];
    List<WaterIntakeDetail> parsedDetails =
    detailsList.map((item) =>
        WaterIntakeDetail.fromJson(item as Map<String, dynamic>)).toList();

    // ⭐️ DailyIntake 문서의 'date' 필드는 Timestamp로 저장되므로,
    // Timestamp에서 DateTime으로 파싱해야 합니다.
    // 만약 문서 ID(dateKey)를 date 필드로 읽어오고 싶다면, FireStore 쿼리에서 'date': doc.id 로 매핑해야 합니다.
    // 현재 FirebaseWaterService의 addWaterIntake에서 'date': Timestamp.fromDate(dailyDate)로 저장하고 있으므로 아래처럼 파싱합니다.
    final DateTime parsedDate = (json['date'] as Timestamp).toDate();


    return DailyIntake(
      userId: json['userId'] as String,
      date: DateTime(parsedDate.year, parsedDate.month, parsedDate.day),
      // 시간 정보 제거하여 순수 날짜로 저장
      totalAmount: (json['totalAmount'] as num).toInt(),
      // num을 int로 변환
      intakeDetails: parsedDetails,
    );
  }

  Map<String, dynamic> toJson() {
    List<Map<String, dynamic>> detailsJsonList =
    intakeDetails.map((detail) => detail.toJson()).toList();

    // DailyIntake 문서 자체의 'date' 필드는 Timestamp로 저장하는 것이 좋습니다.
    // (이전 코드와 동일하게 Timestamp로 저장)
    return {
      'userId': userId,
      'date': Timestamp.fromDate(date),
      'totalAmount': totalAmount,
      'intakeDetails': detailsJsonList,
    };
  }
}