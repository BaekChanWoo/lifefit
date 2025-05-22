import 'package:cloud_firestore/cloud_firestore.dart';

class WaterIntakeDetail {
  final int amount;
  final DateTime intakeTime;

  WaterIntakeDetail({required this.amount, required this.intakeTime});

  factory WaterIntakeDetail.fromJson(Map<String, dynamic> json) {
    // 시간 정보 제거하기
    final DateTime fullDateTime = (json['intakeTime'] as Timestamp).toDate();
    final DateTime dateOnly = DateTime(fullDateTime.year, fullDateTime.month, fullDateTime.day);

    return WaterIntakeDetail(
      amount: json['amount'] as int,
      intakeTime: dateOnly,
    );
  }

  Map<String, dynamic> toJson() {
    //날짜만 변환
    final DateTime dateOnly = DateTime(intakeTime.year, intakeTime.month, intakeTime.day);

    return {
      'amount': amount,
      'intakeTime': Timestamp.fromDate(dateOnly),
    };
  }
}