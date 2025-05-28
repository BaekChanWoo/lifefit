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

    final DateTime parsedDate = (json['date'] as Timestamp).toDate();


    return DailyIntake(
      userId: json['userId'] as String,
      date: DateTime(parsedDate.year, parsedDate.month, parsedDate.day),
      totalAmount: (json['totalAmount'] as num).toInt(),
      intakeDetails: parsedDetails,
    );
  }

  Map<String, dynamic> toJson() {
    List<Map<String, dynamic>> detailsJsonList =
    intakeDetails.map((detail) => detail.toJson()).toList();

    return {
      'userId': userId,
      'date': Timestamp.fromDate(date),
      'totalAmount': totalAmount,
      'intakeDetails': detailsJsonList,
    };
  }
}