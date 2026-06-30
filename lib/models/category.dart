// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'category.freezed.dart';
part 'category.g.dart';

@freezed
class Category with _$Category {
  const factory Category({
    int? id,
    required String name,
    required String color,
    @JsonKey(name: 'is_default') @Default(false) bool isDefault,
    @JsonKey(name: 'user_id') String? userId,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _Category;

  factory Category.fromJson(Map<String, dynamic> json) => _$CategoryFromJson(json);
}
