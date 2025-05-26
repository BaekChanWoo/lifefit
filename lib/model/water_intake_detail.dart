import 'package:cloud_firestore/cloud_firestore.dart';

class WaterIntakeDetail {
  final int amount;
  final DateTime intakeTime; // ⭐️ 물 마신 정확한 시간을 저장

  WaterIntakeDetail({required this.amount, required this.intakeTime});

  factory WaterIntakeDetail.fromJson(Map<String, dynamic> json) {
    // ⭐️ Firebase에서 가져온 'intakeTime' 필드(Timestamp 타입)를
    // DateTime으로 변환할 때 시간 정보를 제거하지 않고 그대로 사용합니다.
    final DateTime fullDateTime = (json['intakeTime'] as Timestamp).toDate();

    return WaterIntakeDetail(
      amount: (json['amount'] as num).toInt(), // Firebase는 숫자를 num으로 가져올 수 있으므로 toInt() 필요
      intakeTime: fullDateTime, // ⭐️ 시간 정보가 포함된 DateTime 그대로 반환
    );
  }

  Map<String, dynamic> toJson() {
    // ⭐️ Dart의 DateTime 객체를 Firebase Timestamp로 변환할 때
    // 시간 정보를 제거하지 않고 그대로 변환합니다.
    return {
      'amount': amount,
      'intakeTime': Timestamp.fromDate(intakeTime), // ⭐️ 시간 정보가 포함된 DateTime 그대로 Timestamp로 변환
    };
  }
}