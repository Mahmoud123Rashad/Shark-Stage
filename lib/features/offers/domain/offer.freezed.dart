// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'offer.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Offer _$OfferFromJson(Map<String, dynamic> json) {
  return _Offer.fromJson(json);
}

/// @nodoc
mixin _$Offer {
  @JsonKey(name: '_id')
  String get id => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  Project? get project => throw _privateConstructorUsedError;
  AppUser? get offeredBy => throw _privateConstructorUsedError;
  AppUser? get offeredTo => throw _privateConstructorUsedError;
  String? get terms => throw _privateConstructorUsedError;
  String? get message => throw _privateConstructorUsedError;

  /// Serializes this Offer to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Offer
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OfferCopyWith<Offer> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OfferCopyWith<$Res> {
  factory $OfferCopyWith(Offer value, $Res Function(Offer) then) =
      _$OfferCopyWithImpl<$Res, Offer>;
  @useResult
  $Res call({
    @JsonKey(name: '_id') String id,
    String status,
    double amount,
    DateTime? createdAt,
    Project? project,
    AppUser? offeredBy,
    AppUser? offeredTo,
    String? terms,
    String? message,
  });

  $ProjectCopyWith<$Res>? get project;
  $AppUserCopyWith<$Res>? get offeredBy;
  $AppUserCopyWith<$Res>? get offeredTo;
}

/// @nodoc
class _$OfferCopyWithImpl<$Res, $Val extends Offer>
    implements $OfferCopyWith<$Res> {
  _$OfferCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Offer
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? status = null,
    Object? amount = null,
    Object? createdAt = freezed,
    Object? project = freezed,
    Object? offeredBy = freezed,
    Object? offeredTo = freezed,
    Object? terms = freezed,
    Object? message = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            amount: null == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                      as double,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            project: freezed == project
                ? _value.project
                : project // ignore: cast_nullable_to_non_nullable
                      as Project?,
            offeredBy: freezed == offeredBy
                ? _value.offeredBy
                : offeredBy // ignore: cast_nullable_to_non_nullable
                      as AppUser?,
            offeredTo: freezed == offeredTo
                ? _value.offeredTo
                : offeredTo // ignore: cast_nullable_to_non_nullable
                      as AppUser?,
            terms: freezed == terms
                ? _value.terms
                : terms // ignore: cast_nullable_to_non_nullable
                      as String?,
            message: freezed == message
                ? _value.message
                : message // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }

  /// Create a copy of Offer
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ProjectCopyWith<$Res>? get project {
    if (_value.project == null) {
      return null;
    }

    return $ProjectCopyWith<$Res>(_value.project!, (value) {
      return _then(_value.copyWith(project: value) as $Val);
    });
  }

  /// Create a copy of Offer
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AppUserCopyWith<$Res>? get offeredBy {
    if (_value.offeredBy == null) {
      return null;
    }

    return $AppUserCopyWith<$Res>(_value.offeredBy!, (value) {
      return _then(_value.copyWith(offeredBy: value) as $Val);
    });
  }

  /// Create a copy of Offer
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AppUserCopyWith<$Res>? get offeredTo {
    if (_value.offeredTo == null) {
      return null;
    }

    return $AppUserCopyWith<$Res>(_value.offeredTo!, (value) {
      return _then(_value.copyWith(offeredTo: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$OfferImplCopyWith<$Res> implements $OfferCopyWith<$Res> {
  factory _$$OfferImplCopyWith(
    _$OfferImpl value,
    $Res Function(_$OfferImpl) then,
  ) = __$$OfferImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: '_id') String id,
    String status,
    double amount,
    DateTime? createdAt,
    Project? project,
    AppUser? offeredBy,
    AppUser? offeredTo,
    String? terms,
    String? message,
  });

  @override
  $ProjectCopyWith<$Res>? get project;
  @override
  $AppUserCopyWith<$Res>? get offeredBy;
  @override
  $AppUserCopyWith<$Res>? get offeredTo;
}

/// @nodoc
class __$$OfferImplCopyWithImpl<$Res>
    extends _$OfferCopyWithImpl<$Res, _$OfferImpl>
    implements _$$OfferImplCopyWith<$Res> {
  __$$OfferImplCopyWithImpl(
    _$OfferImpl _value,
    $Res Function(_$OfferImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Offer
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? status = null,
    Object? amount = null,
    Object? createdAt = freezed,
    Object? project = freezed,
    Object? offeredBy = freezed,
    Object? offeredTo = freezed,
    Object? terms = freezed,
    Object? message = freezed,
  }) {
    return _then(
      _$OfferImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        amount: null == amount
            ? _value.amount
            : amount // ignore: cast_nullable_to_non_nullable
                  as double,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        project: freezed == project
            ? _value.project
            : project // ignore: cast_nullable_to_non_nullable
                  as Project?,
        offeredBy: freezed == offeredBy
            ? _value.offeredBy
            : offeredBy // ignore: cast_nullable_to_non_nullable
                  as AppUser?,
        offeredTo: freezed == offeredTo
            ? _value.offeredTo
            : offeredTo // ignore: cast_nullable_to_non_nullable
                  as AppUser?,
        terms: freezed == terms
            ? _value.terms
            : terms // ignore: cast_nullable_to_non_nullable
                  as String?,
        message: freezed == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$OfferImpl implements _Offer {
  const _$OfferImpl({
    @JsonKey(name: '_id') required this.id,
    required this.status,
    this.amount = 0,
    this.createdAt,
    this.project,
    this.offeredBy,
    this.offeredTo,
    this.terms,
    this.message,
  });

  factory _$OfferImpl.fromJson(Map<String, dynamic> json) =>
      _$$OfferImplFromJson(json);

  @override
  @JsonKey(name: '_id')
  final String id;
  @override
  final String status;
  @override
  @JsonKey()
  final double amount;
  @override
  final DateTime? createdAt;
  @override
  final Project? project;
  @override
  final AppUser? offeredBy;
  @override
  final AppUser? offeredTo;
  @override
  final String? terms;
  @override
  final String? message;

  @override
  String toString() {
    return 'Offer(id: $id, status: $status, amount: $amount, createdAt: $createdAt, project: $project, offeredBy: $offeredBy, offeredTo: $offeredTo, terms: $terms, message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OfferImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.project, project) || other.project == project) &&
            (identical(other.offeredBy, offeredBy) ||
                other.offeredBy == offeredBy) &&
            (identical(other.offeredTo, offeredTo) ||
                other.offeredTo == offeredTo) &&
            (identical(other.terms, terms) || other.terms == terms) &&
            (identical(other.message, message) || other.message == message));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    status,
    amount,
    createdAt,
    project,
    offeredBy,
    offeredTo,
    terms,
    message,
  );

  /// Create a copy of Offer
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OfferImplCopyWith<_$OfferImpl> get copyWith =>
      __$$OfferImplCopyWithImpl<_$OfferImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OfferImplToJson(this);
  }
}

abstract class _Offer implements Offer {
  const factory _Offer({
    @JsonKey(name: '_id') required final String id,
    required final String status,
    final double amount,
    final DateTime? createdAt,
    final Project? project,
    final AppUser? offeredBy,
    final AppUser? offeredTo,
    final String? terms,
    final String? message,
  }) = _$OfferImpl;

  factory _Offer.fromJson(Map<String, dynamic> json) = _$OfferImpl.fromJson;

  @override
  @JsonKey(name: '_id')
  String get id;
  @override
  String get status;
  @override
  double get amount;
  @override
  DateTime? get createdAt;
  @override
  Project? get project;
  @override
  AppUser? get offeredBy;
  @override
  AppUser? get offeredTo;
  @override
  String? get terms;
  @override
  String? get message;

  /// Create a copy of Offer
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OfferImplCopyWith<_$OfferImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
