// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ExpenseImpl _$$ExpenseImplFromJson(Map<String, dynamic> json) =>
    _$ExpenseImpl(
      id: (json['id'] as num?)?.toInt(),
      userId: json['user_id'] as String,
      categoryId: (json['category_id'] as num?)?.toInt(),
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      paymentMode: json['payment_mode'] as String,
      expenseDate: DateTime.parse(json['expense_date'] as String),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      category: json['categories'] == null
          ? null
          : Category.fromJson(json['categories'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$ExpenseImplToJson(_$ExpenseImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'category_id': instance.categoryId,
      'title': instance.title,
      'amount': instance.amount,
      'payment_mode': instance.paymentMode,
      'expense_date': instance.expenseDate.toIso8601String(),
      'created_at': instance.createdAt?.toIso8601String(),
      'categories': instance.category,
    };
