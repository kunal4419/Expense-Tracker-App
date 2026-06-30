// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CategoryImpl _$$CategoryImplFromJson(Map<String, dynamic> json) =>
    _$CategoryImpl(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String,
      color: json['color'] as String,
      isDefault: json['is_default'] as bool? ?? false,
      userId: json['user_id'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$CategoryImplToJson(_$CategoryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'color': instance.color,
      'is_default': instance.isDefault,
      'user_id': instance.userId,
      'created_at': instance.createdAt?.toIso8601String(),
    };
