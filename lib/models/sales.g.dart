// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sales.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SalesImpl _$$SalesImplFromJson(Map<String, dynamic> json) => _$SalesImpl(
  id: (json['id'] as num?)?.toInt(),
  userId: json['user_id'] as String,
  morningSales: (json['morning_sales'] as num).toDouble(),
  eveningSales: (json['evening_sales'] as num).toDouble(),
  entryDate: DateTime.parse(json['entry_date'] as String),
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$$SalesImplToJson(_$SalesImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'morning_sales': instance.morningSales,
      'evening_sales': instance.eveningSales,
      'entry_date': instance.entryDate.toIso8601String(),
      'created_at': instance.createdAt?.toIso8601String(),
    };
