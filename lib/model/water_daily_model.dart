//물 그래프용 일별 총량
import 'package:lifefit/model/water_intake_detail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DailyIntake {
  final int totalAmount;
  final List<WaterIntakeDetail> intakeDetails;
  final bool isAchievementShown;

  DailyIntake({
    required this.totalAmount,
    required this.intakeDetails,
    required this.isAchievementShown,
  });

  factory DailyIntake.fromJson(Map<String, dynamic> json) {
    final detailsJson = json['intakeDetails'] as List<dynamic>? ?? [];
    final details = detailsJson
        .map((e) => WaterIntakeDetail(
      amount: e['amount'],
      intakeTime: (e['intakeTime'] as Timestamp).toDate(),
    ))
        .toList();

    return DailyIntake(
      totalAmount: json['totalAmount'] ?? 0,
      intakeDetails: details,
      isAchievementShown: json['isAchievementShown'] ?? false,
    );
  }
}