// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sleep_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SleepModel _$SleepModelFromJson(Map<String, dynamic> json) => SleepModel(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      sleepHours: (json['sleepHours'] as num).toDouble(),
      userId: json['userId'] as String,
    );

Map<String, dynamic> _$SleepModelToJson(SleepModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'date': instance.date.toIso8601String(),
      'sleepHours': instance.sleepHours,
      'userId': instance.userId,
    };
