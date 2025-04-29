import 'package:json_annotation/json_annotation.dart';

part 'sleep_model.g.dart';  //자동 생성되는 파일. 변환 코드가 들어감

@JsonSerializable() //자동으로 JSON 변환 코드를 만들어줌
class SleepModel {
  final String id;
  final DateTime date;  //기록된 날짜
  final double sleepHours;//수면 시간
  final String userId;    // 사용자 ID


  SleepModel({  //require -> 무조건 값을 넣게 강제함
    required this.id,
    required this.date,
    required this.sleepHours,
    required this.userId,
  });

  // JSON -> SleepModel 변환 (파이어베이스에서 받아올 때)
  factory SleepModel.fromJson(Map<String, dynamic> json) => _$SleepModelFromJson(json);

  // SleepModel -> JSON 변환 (파이어베이스에서 사용할 때)
  Map<String, dynamic> toJson() => _$SleepModelToJson(this);
}
