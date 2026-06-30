// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sales.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Sales _$SalesFromJson(Map<String, dynamic> json) {
  return _Sales.fromJson(json);
}

/// @nodoc
mixin _$Sales {
  int? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  @JsonKey(name: 'morning_sales')
  double get morningSales => throw _privateConstructorUsedError;
  @JsonKey(name: 'evening_sales')
  double get eveningSales => throw _privateConstructorUsedError;
  @JsonKey(name: 'entry_date')
  DateTime get entryDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this Sales to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Sales
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SalesCopyWith<Sales> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SalesCopyWith<$Res> {
  factory $SalesCopyWith(Sales value, $Res Function(Sales) then) =
      _$SalesCopyWithImpl<$Res, Sales>;
  @useResult
  $Res call({
    int? id,
    @JsonKey(name: 'user_id') String userId,
    @JsonKey(name: 'morning_sales') double morningSales,
    @JsonKey(name: 'evening_sales') double eveningSales,
    @JsonKey(name: 'entry_date') DateTime entryDate,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  });
}

/// @nodoc
class _$SalesCopyWithImpl<$Res, $Val extends Sales>
    implements $SalesCopyWith<$Res> {
  _$SalesCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Sales
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? userId = null,
    Object? morningSales = null,
    Object? eveningSales = null,
    Object? entryDate = null,
    Object? createdAt = freezed,
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
            morningSales: null == morningSales
                ? _value.morningSales
                : morningSales // ignore: cast_nullable_to_non_nullable
                      as double,
            eveningSales: null == eveningSales
                ? _value.eveningSales
                : eveningSales // ignore: cast_nullable_to_non_nullable
                      as double,
            entryDate: null == entryDate
                ? _value.entryDate
                : entryDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SalesImplCopyWith<$Res> implements $SalesCopyWith<$Res> {
  factory _$$SalesImplCopyWith(
    _$SalesImpl value,
    $Res Function(_$SalesImpl) then,
  ) = __$$SalesImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int? id,
    @JsonKey(name: 'user_id') String userId,
    @JsonKey(name: 'morning_sales') double morningSales,
    @JsonKey(name: 'evening_sales') double eveningSales,
    @JsonKey(name: 'entry_date') DateTime entryDate,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  });
}

/// @nodoc
class __$$SalesImplCopyWithImpl<$Res>
    extends _$SalesCopyWithImpl<$Res, _$SalesImpl>
    implements _$$SalesImplCopyWith<$Res> {
  __$$SalesImplCopyWithImpl(
    _$SalesImpl _value,
    $Res Function(_$SalesImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Sales
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? userId = null,
    Object? morningSales = null,
    Object? eveningSales = null,
    Object? entryDate = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$SalesImpl(
        id: freezed == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int?,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        morningSales: null == morningSales
            ? _value.morningSales
            : morningSales // ignore: cast_nullable_to_non_nullable
                  as double,
        eveningSales: null == eveningSales
            ? _value.eveningSales
            : eveningSales // ignore: cast_nullable_to_non_nullable
                  as double,
        entryDate: null == entryDate
            ? _value.entryDate
            : entryDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SalesImpl implements _Sales {
  const _$SalesImpl({
    this.id,
    @JsonKey(name: 'user_id') required this.userId,
    @JsonKey(name: 'morning_sales') required this.morningSales,
    @JsonKey(name: 'evening_sales') required this.eveningSales,
    @JsonKey(name: 'entry_date') required this.entryDate,
    @JsonKey(name: 'created_at') this.createdAt,
  });

  factory _$SalesImpl.fromJson(Map<String, dynamic> json) =>
      _$$SalesImplFromJson(json);

  @override
  final int? id;
  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  @JsonKey(name: 'morning_sales')
  final double morningSales;
  @override
  @JsonKey(name: 'evening_sales')
  final double eveningSales;
  @override
  @JsonKey(name: 'entry_date')
  final DateTime entryDate;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @override
  String toString() {
    return 'Sales(id: $id, userId: $userId, morningSales: $morningSales, eveningSales: $eveningSales, entryDate: $entryDate, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SalesImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.morningSales, morningSales) ||
                other.morningSales == morningSales) &&
            (identical(other.eveningSales, eveningSales) ||
                other.eveningSales == eveningSales) &&
            (identical(other.entryDate, entryDate) ||
                other.entryDate == entryDate) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    morningSales,
    eveningSales,
    entryDate,
    createdAt,
  );

  /// Create a copy of Sales
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SalesImplCopyWith<_$SalesImpl> get copyWith =>
      __$$SalesImplCopyWithImpl<_$SalesImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SalesImplToJson(this);
  }
}

abstract class _Sales implements Sales {
  const factory _Sales({
    final int? id,
    @JsonKey(name: 'user_id') required final String userId,
    @JsonKey(name: 'morning_sales') required final double morningSales,
    @JsonKey(name: 'evening_sales') required final double eveningSales,
    @JsonKey(name: 'entry_date') required final DateTime entryDate,
    @JsonKey(name: 'created_at') final DateTime? createdAt,
  }) = _$SalesImpl;

  factory _Sales.fromJson(Map<String, dynamic> json) = _$SalesImpl.fromJson;

  @override
  int? get id;
  @override
  @JsonKey(name: 'user_id')
  String get userId;
  @override
  @JsonKey(name: 'morning_sales')
  double get morningSales;
  @override
  @JsonKey(name: 'evening_sales')
  double get eveningSales;
  @override
  @JsonKey(name: 'entry_date')
  DateTime get entryDate;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;

  /// Create a copy of Sales
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SalesImplCopyWith<_$SalesImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
