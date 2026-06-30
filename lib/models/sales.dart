// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'sales.freezed.dart';
part 'sales.g.dart';

@freezed
class Sales with _$Sales {
  const factory Sales({
    int? id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'morning_sales') required double morningSales,
    @JsonKey(name: 'evening_sales') required double eveningSales,
    @JsonKey(name: 'entry_date') required DateTime entryDate,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _Sales;

  factory Sales.fromJson(Map<String, dynamic> json) => _$SalesFromJson(json);
}
