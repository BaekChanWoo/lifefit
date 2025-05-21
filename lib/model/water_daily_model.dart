//물 그래프용 일별 총량
import 'package:lifefit/model/water_intake_detail.dart';

class DailyIntake {
  final String userId;
  final DateTime date;
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
    detailsList.map((item) => WaterIntakeDetail.fromJson(item as Map<String, dynamic>)).toList();

    return DailyIntake(
      userId: json['userId'] as String,
      date: DateTime.parse(json['date'] as String),
      totalAmount: json['totalAmount'] as int,
      intakeDetails: parsedDetails,
    );
  }

  Map<String, dynamic> toJson() {
    List<Map<String, dynamic>> detailsJsonList =
    intakeDetails.map((detail) => detail.toJson()).toList();

    return {
      'userId': userId,
      'date': '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
      'totalAmount': totalAmount,
      'intakeDetails': detailsJsonList,
    };
  }
}