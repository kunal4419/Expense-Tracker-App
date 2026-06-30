// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'expense.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Expense _$ExpenseFromJson(Map<String, dynamic> json) {
  return _Expense.fromJson(json);
}

/// @nodoc
mixin _$Expense {
  int? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  @JsonKey(name: 'category_id')
  int? get categoryId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  @JsonKey(name: 'payment_mode')
  String get paymentMode => throw _privateConstructorUsedError;
  @JsonKey(name: 'expense_date')
  DateTime get expenseDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError; // Maps the joined categories relation from Supabase
  @JsonKey(name: 'categories')
  Category? get category => throw _privateConstructorUsedError;

  /// Serializes this Expense to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Expense
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExpenseCopyWith<Expense> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExpenseCopyWith<$Res> {
  factory $ExpenseCopyWith(Expense value, $Res Function(Expense) then) =
      _$ExpenseCopyWithImpl<$Res, Expense>;
  @useResult
  $Res call({
    int? id,
    @JsonKey(name: 'user_id') String userId,
    @JsonKey(name: 'category_id') int? categoryId,
    String title,
    double amount,
    @JsonKey(name: 'payment_mode') String paymentMode,
    @JsonKey(name: 'expense_date') DateTime expenseDate,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'categories') Category? category,
  });

  $CategoryCopyWith<$Res>? get category;
}

/// @nodoc
class _$ExpenseCopyWithImpl<$Res, $Val extends Expense>
    implements $ExpenseCopyWith<$Res> {
  _$ExpenseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Expense
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? userId = null,
    Object? categoryId = freezed,
    Object? title = null,
    Object? amount = null,
    Object? paymentMode = null,
    Object? expenseDate = null,
    Object? createdAt = freezed,
    Object? category = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int?,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            categoryId: freezed == categoryId
                ? _value.categoryId
                : categoryId // ignore: cast_nullable_to_non_nullable
                      as int?,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            amount: null == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                      as double,
            paymentMode: null == paymentMode
                ? _value.paymentMode
                : paymentMode // ignore: cast_nullable_to_non_nullable
                      as String,
            expenseDate: null == expenseDate
                ? _value.expenseDate
                : expenseDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            category: freezed == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as Category?,
          )
          as $Val,
    );
  }

  /// Create a copy of Expense
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CategoryCopyWith<$Res>? get category {
    if (_value.category == null) {
      return null;
    }

    return $CategoryCopyWith<$Res>(_value.category!, (value) {
      return _then(_value.copyWith(category: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ExpenseImplCopyWith<$Res> implements $ExpenseCopyWith<$Res> {
  factory _$$ExpenseImplCopyWith(
    _$ExpenseImpl value,
    $Res Function(_$ExpenseImpl) then,
  ) = __$$ExpenseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int? id,
    @JsonKey(name: 'user_id') String userId,
    @JsonKey(name: 'category_id') int? categoryId,
    String title,
    double amount,
    @JsonKey(name: 'payment_mode') String paymentMode,
    @JsonKey(name: 'expense_date') DateTime expenseDate,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'categories') Category? category,
  });

  @override
  $CategoryCopyWith<$Res>? get category;
}

/// @nodoc
class __$$ExpenseImplCopyWithImpl<$Res>
    extends _$ExpenseCopyWithImpl<$Res, _$ExpenseImpl>
    implements _$$ExpenseImplCopyWith<$Res> {
  __$$ExpenseImplCopyWithImpl(
    _$ExpenseImpl _value,
    $Res Function(_$ExpenseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Expense
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? userId = null,
    Object? categoryId = freezed,
    Object? title = null,
    Object? amount = null,
    Object? paymentMode = null,
    Object? expenseDate = null,
    Object? createdAt = freezed,
    Object? category = freezed,
  }) {
    return _then(
      _$ExpenseImpl(
        id: freezed == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int?,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        categoryId: freezed == categoryId
            ? _value.categoryId
            : categoryId // ignore: cast_nullable_to_non_nullable
                  as int?,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        amount: null == amount
            ? _value.amount
            : amount // ignore: cast_nullable_to_non_nullable
                  as double,
        paymentMode: null == paymentMode
            ? _value.paymentMode
            : paymentMode // ignore: cast_nullable_to_non_nullable
                  as String,
        expenseDate: null == expenseDate
            ? _value.expenseDate
            : expenseDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        category: freezed == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as Category?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ExpenseImpl implements _Expense {
  const _$ExpenseImpl({
    this.id,
    @JsonKey(name: 'user_id') required this.userId,
    @JsonKey(name: 'category_id') this.categoryId,
    required this.title,
    required this.amount,
    @JsonKey(name: 'payment_mode') required this.paymentMode,
    @JsonKey(name: 'expense_date') required this.expenseDate,
    @JsonKey(name: 'created_at') this.createdAt,
    @JsonKey(name: 'categories') this.category,
  });

  factory _$ExpenseImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExpenseImplFromJson(json);

  @override
  final int? id;
  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  @JsonKey(name: 'category_id')
  final int? categoryId;
  @override
  final String title;
  @override
  final double amount;
  @override
  @JsonKey(name: 'payment_mode')
  final String paymentMode;
  @override
  @JsonKey(name: 'expense_date')
  final DateTime expenseDate;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  // Maps the joined categories relation from Supabase
  @override
  @JsonKey(name: 'categories')
  final Category? category;

  @override
  String toString() {
    return 'Expense(id: $id, userId: $userId, categoryId: $categoryId, title: $title, amount: $amount, paymentMode: $paymentMode, expenseDate: $expenseDate, createdAt: $createdAt, category: $category)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExpenseImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.categoryId, categoryId) ||
                other.categoryId == categoryId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.paymentMode, paymentMode) ||
                other.paymentMode == paymentMode) &&
            (identical(other.expenseDate, expenseDate) ||
                other.expenseDate == expenseDate) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.category, category) ||
                other.category == category));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    categoryId,
    title,
    amount,
    paymentMode,
    expenseDate,
    createdAt,
    category,
  );

  /// Create a copy of Expense
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExpenseImplCopyWith<_$ExpenseImpl> get copyWith =>
      __$$ExpenseImplCopyWithImpl<_$ExpenseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ExpenseImplToJson(this);
  }
}

abstract class _Expense implements Expense {
  const factory _Expense({
    final int? id,
    @JsonKey(name: 'user_id') required final String userId,
    @JsonKey(name: 'category_id') final int? categoryId,
    required final String title,
    required final double amount,
    @JsonKey(name: 'payment_mode') required final String paymentMode,
    @JsonKey(name: 'expense_date') required final DateTime expenseDate,
    @JsonKey(name: 'created_at') final DateTime? createdAt,
    @JsonKey(name: 'categories') final Category? category,
  }) = _$ExpenseImpl;

  factory _Expense.fromJson(Map<String, dynamic> json) = _$ExpenseImpl.fromJson;

  @override
  int? get id;
  @override
  @JsonKey(name: 'user_id')
  String get userId;
  @override
  @JsonKey(name: 'category_id')
  int? get categoryId;
  @override
  String get title;
  @override
  double get amount;
  @override
  @JsonKey(name: 'payment_mode')
  String get paymentMode;
  @override
  @JsonKey(name: 'expense_date')
  DateTime get expenseDate;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt; // Maps the joined categories relation from Supabase
  @override
  @JsonKey(name: 'categories')
  Category? get category;

  /// Create a copy of Expense
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExpenseImplCopyWith<_$ExpenseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
