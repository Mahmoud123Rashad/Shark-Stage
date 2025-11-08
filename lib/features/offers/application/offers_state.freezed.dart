// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'offers_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$OffersState {
  List<Offer> get sent => throw _privateConstructorUsedError;
  List<Offer> get received => throw _privateConstructorUsedError;
  bool get loading => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;

  /// Create a copy of OffersState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OffersStateCopyWith<OffersState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OffersStateCopyWith<$Res> {
  factory $OffersStateCopyWith(
    OffersState value,
    $Res Function(OffersState) then,
  ) = _$OffersStateCopyWithImpl<$Res, OffersState>;
  @useResult
  $Res call({
    List<Offer> sent,
    List<Offer> received,
    bool loading,
    String? error,
  });
}

/// @nodoc
class _$OffersStateCopyWithImpl<$Res, $Val extends OffersState>
    implements $OffersStateCopyWith<$Res> {
  _$OffersStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OffersState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sent = null,
    Object? received = null,
    Object? loading = null,
    Object? error = freezed,
  }) {
    return _then(
      _value.copyWith(
            sent: null == sent
                ? _value.sent
                : sent // ignore: cast_nullable_to_non_nullable
                      as List<Offer>,
            received: null == received
                ? _value.received
                : received // ignore: cast_nullable_to_non_nullable
                      as List<Offer>,
            loading: null == loading
                ? _value.loading
                : loading // ignore: cast_nullable_to_non_nullable
                      as bool,
            error: freezed == error
                ? _value.error
                : error // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$OffersStateImplCopyWith<$Res>
    implements $OffersStateCopyWith<$Res> {
  factory _$$OffersStateImplCopyWith(
    _$OffersStateImpl value,
    $Res Function(_$OffersStateImpl) then,
  ) = __$$OffersStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<Offer> sent,
    List<Offer> received,
    bool loading,
    String? error,
  });
}

/// @nodoc
class __$$OffersStateImplCopyWithImpl<$Res>
    extends _$OffersStateCopyWithImpl<$Res, _$OffersStateImpl>
    implements _$$OffersStateImplCopyWith<$Res> {
  __$$OffersStateImplCopyWithImpl(
    _$OffersStateImpl _value,
    $Res Function(_$OffersStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OffersState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sent = null,
    Object? received = null,
    Object? loading = null,
    Object? error = freezed,
  }) {
    return _then(
      _$OffersStateImpl(
        sent: null == sent
            ? _value._sent
            : sent // ignore: cast_nullable_to_non_nullable
                  as List<Offer>,
        received: null == received
            ? _value._received
            : received // ignore: cast_nullable_to_non_nullable
                  as List<Offer>,
        loading: null == loading
            ? _value.loading
            : loading // ignore: cast_nullable_to_non_nullable
                  as bool,
        error: freezed == error
            ? _value.error
            : error // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$OffersStateImpl implements _OffersState {
  const _$OffersStateImpl({
    final List<Offer> sent = const <Offer>[],
    final List<Offer> received = const <Offer>[],
    this.loading = false,
    this.error,
  }) : _sent = sent,
       _received = received;

  final List<Offer> _sent;
  @override
  @JsonKey()
  List<Offer> get sent {
    if (_sent is EqualUnmodifiableListView) return _sent;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_sent);
  }

  final List<Offer> _received;
  @override
  @JsonKey()
  List<Offer> get received {
    if (_received is EqualUnmodifiableListView) return _received;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_received);
  }

  @override
  @JsonKey()
  final bool loading;
  @override
  final String? error;

  @override
  String toString() {
    return 'OffersState(sent: $sent, received: $received, loading: $loading, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OffersStateImpl &&
            const DeepCollectionEquality().equals(other._sent, _sent) &&
            const DeepCollectionEquality().equals(other._received, _received) &&
            (identical(other.loading, loading) || other.loading == loading) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_sent),
    const DeepCollectionEquality().hash(_received),
    loading,
    error,
  );

  /// Create a copy of OffersState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OffersStateImplCopyWith<_$OffersStateImpl> get copyWith =>
      __$$OffersStateImplCopyWithImpl<_$OffersStateImpl>(this, _$identity);
}

abstract class _OffersState implements OffersState {
  const factory _OffersState({
    final List<Offer> sent,
    final List<Offer> received,
    final bool loading,
    final String? error,
  }) = _$OffersStateImpl;

  @override
  List<Offer> get sent;
  @override
  List<Offer> get received;
  @override
  bool get loading;
  @override
  String? get error;

  /// Create a copy of OffersState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OffersStateImplCopyWith<_$OffersStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
