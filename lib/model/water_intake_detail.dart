import 'package:cloud_firestore/cloud_firestore.dart';

class WaterIntakeDetail {
  final int amount;
  final DateTime intakeTime;

  WaterIntakeDetail({required this.amount, required this.intakeTime});

  factory WaterIntakeDetail.fromJson(Map<String, dynamic> json) {

    final DateTime fullDateTime = (json['intakeTime'] as Timestamp).toDate();

    return WaterIntakeDetail(
      amount: (json['amount'] as num).toInt(),
      intakeTime: fullDateTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'intakeTime': Timestamp.fromDate(intakeTime),
    };
  }
}