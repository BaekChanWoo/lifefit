//물 섭취량
class WaterIntakeRecord {
  final String userId;
  final int amount;

  WaterIntakeRecord({required this.userId, required this.amount });

  factory WaterIntakeRecord.fromJson(Map<String, dynamic> json) {
    return WaterIntakeRecord(
      userId: json['userId'] as String,
      amount: json['amount'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'amount': amount, //
    };
  }
}

//물 그래프
class DailyIntake {
  final String userId;
  final DateTime date;
  final int totalAmount;

  DailyIntake({
    required this.userId,
    required this.date,
    required this.totalAmount});

  factory DailyIntake.fromJson(Map<String, dynamic> json) {

    return DailyIntake(
      userId: json['userId'] as String,
      date: DateTime.parse(json['date'] as String),
      totalAmount: json['totalAmount'] as int,
    );

  }



  Map<String, dynamic> toJson() {

    return {
      'userId': userId,
      'date': date.toIso8601String(),
      'totalAmount': totalAmount,
    };
  }
}