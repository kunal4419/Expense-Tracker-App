// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'category.dart';

part 'expense.freezed.dart';
part 'expense.g.dart';

@freezed
class Expense with _$Expense {
  const factory Expense({
    int? id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'category_id') int? categoryId,
    required String title,
    required double amount,
    @JsonKey(name: 'payment_mode') required String paymentMode,
    @JsonKey(name: 'expense_date') required DateTime expenseDate,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    // Maps the joined categories relation from Supabase
    @JsonKey(name: 'categories') Category? category,
  }) = _Expense;

  factory Expense.fromJson(Map<String, dynamic> json) => _$ExpenseFromJson(json);
}
