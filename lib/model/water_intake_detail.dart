import 'package:cloud_firestore/cloud_firestore.dart';

class WaterIntakeDetail {
  final int amount;
  final DateTime intakeTime;

  WaterIntakeDetail({required this.amount, required this.intakeTime});

  Map<String, dynamic> toJson() => {
    'amount': amount,
    'intakeTime': Timestamp.fromDate(intakeTime),
  };
}