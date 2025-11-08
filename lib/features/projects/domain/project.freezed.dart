// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'project.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Project _$ProjectFromJson(Map<String, dynamic> json) {
  return _Project.fromJson(json);
}

/// @nodoc
mixin _$Project {
  @JsonKey(name: '_id')
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get shortDesc => throw _privateConstructorUsedError;
  ProjectCategory get category => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  @JsonKey(defaultValue: 0)
  double? get totalPrice => throw _privateConstructorUsedError;
  @JsonKey(defaultValue: 0)
  double? get expectedROI => throw _privateConstructorUsedError;
  @JsonKey(defaultValue: 0)
  double? get availablePercentage => throw _privateConstructorUsedError;
  @JsonKey(defaultValue: 0)
  double? get progress => throw _privateConstructorUsedError;
  String? get image => throw _privateConstructorUsedError;
  List<String> get potentialRisks => throw _privateConstructorUsedError;
  List<String> get keyBenefits => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Project to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Project
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProjectCopyWith<Project> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProjectCopyWith<$Res> {
  factory $ProjectCopyWith(Project value, $Res Function(Project) then) =
      _$ProjectCopyWithImpl<$Res, Project>;
  @useResult
  $Res call({
    @JsonKey(name: '_id') String id,
    String title,
    String description,
    String shortDesc,
    ProjectCategory category,
    String status,
    @JsonKey(defaultValue: 0) double? totalPrice,
    @JsonKey(defaultValue: 0) double? expectedROI,
    @JsonKey(defaultValue: 0) double? availablePercentage,
    @JsonKey(defaultValue: 0) double? progress,
    String? image,
    List<String> potentialRisks,
    List<String> keyBenefits,
    DateTime? createdAt,
    DateTime? updatedAt,
  });

  $ProjectCategoryCopyWith<$Res> get category;
}

/// @nodoc
class _$ProjectCopyWithImpl<$Res, $Val extends Project>
    implements $ProjectCopyWith<$Res> {
  _$ProjectCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Project
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? shortDesc = null,
    Object? category = null,
    Object? status = null,
    Object? totalPrice = freezed,
    Object? expectedROI = freezed,
    Object? availablePercentage = freezed,
    Object? progress = freezed,
    Object? image = freezed,
    Object? potentialRisks = null,
    Object? keyBenefits = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            shortDesc: null == shortDesc
                ? _value.shortDesc
                : shortDesc // ignore: cast_nullable_to_non_nullable
                      as String,
            category: null == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as ProjectCategory,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            totalPrice: freezed == totalPrice
                ? _value.totalPrice
                : totalPrice // ignore: cast_nullable_to_non_nullable
                      as double?,
            expectedROI: freezed == expectedROI
                ? _value.expectedROI
                : expectedROI // ignore: cast_nullable_to_non_nullable
                      as double?,
            availablePercentage: freezed == availablePercentage
                ? _value.availablePercentage
                : availablePercentage // ignore: cast_nullable_to_non_nullable
                      as double?,
            progress: freezed == progress
                ? _value.progress
                : progress // ignore: cast_nullable_to_non_nullable
                      as double?,
            image: freezed == image
                ? _value.image
                : image // ignore: cast_nullable_to_non_nullable
                      as String?,
            potentialRisks: null == potentialRisks
                ? _value.potentialRisks
                : potentialRisks // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            keyBenefits: null == keyBenefits
                ? _value.keyBenefits
                : keyBenefits // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }

  /// Create a copy of Project
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ProjectCategoryCopyWith<$Res> get category {
    return $ProjectCategoryCopyWith<$Res>(_value.category, (value) {
      return _then(_value.copyWith(category: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ProjectImplCopyWith<$Res> implements $ProjectCopyWith<$Res> {
  factory _$$ProjectImplCopyWith(
    _$ProjectImpl value,
    $Res Function(_$ProjectImpl) then,
  ) = __$$ProjectImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: '_id') String id,
    String title,
    String description,
    String shortDesc,
    ProjectCategory category,
    String status,
    @JsonKey(defaultValue: 0) double? totalPrice,
    @JsonKey(defaultValue: 0) double? expectedROI,
    @JsonKey(defaultValue: 0) double? availablePercentage,
    @JsonKey(defaultValue: 0) double? progress,
    String? image,
    List<String> potentialRisks,
    List<String> keyBenefits,
    DateTime? createdAt,
    DateTime? updatedAt,
  });

  @override
  $ProjectCategoryCopyWith<$Res> get category;
}

/// @nodoc
class __$$ProjectImplCopyWithImpl<$Res>
    extends _$ProjectCopyWithImpl<$Res, _$ProjectImpl>
    implements _$$ProjectImplCopyWith<$Res> {
  __$$ProjectImplCopyWithImpl(
    _$ProjectImpl _value,
    $Res Function(_$ProjectImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Project
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? shortDesc = null,
    Object? category = null,
    Object? status = null,
    Object? totalPrice = freezed,
    Object? expectedROI = freezed,
    Object? availablePercentage = freezed,
    Object? progress = freezed,
    Object? image = freezed,
    Object? potentialRisks = null,
    Object? keyBenefits = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$ProjectImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        shortDesc: null == shortDesc
            ? _value.shortDesc
            : shortDesc // ignore: cast_nullable_to_non_nullable
                  as String,
        category: null == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as ProjectCategory,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        totalPrice: freezed == totalPrice
            ? _value.totalPrice
            : totalPrice // ignore: cast_nullable_to_non_nullable
                  as double?,
        expectedROI: freezed == expectedROI
            ? _value.expectedROI
            : expectedROI // ignore: cast_nullable_to_non_nullable
                  as double?,
        availablePercentage: freezed == availablePercentage
            ? _value.availablePercentage
            : availablePercentage // ignore: cast_nullable_to_non_nullable
                  as double?,
        progress: freezed == progress
            ? _value.progress
            : progress // ignore: cast_nullable_to_non_nullable
                  as double?,
        image: freezed == image
            ? _value.image
            : image // ignore: cast_nullable_to_non_nullable
                  as String?,
        potentialRisks: null == potentialRisks
            ? _value._potentialRisks
            : potentialRisks // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        keyBenefits: null == keyBenefits
            ? _value._keyBenefits
            : keyBenefits // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ProjectImpl implements _Project {
  const _$ProjectImpl({
    @JsonKey(name: '_id') required this.id,
    required this.title,
    required this.description,
    this.shortDesc = '',
    this.category = const ProjectCategory(),
    this.status = 'active',
    @JsonKey(defaultValue: 0) this.totalPrice,
    @JsonKey(defaultValue: 0) this.expectedROI,
    @JsonKey(defaultValue: 0) this.availablePercentage,
    @JsonKey(defaultValue: 0) this.progress,
    this.image,
    final List<String> potentialRisks = const <String>[],
    final List<String> keyBenefits = const <String>[],
    this.createdAt,
    this.updatedAt,
  }) : _potentialRisks = potentialRisks,
       _keyBenefits = keyBenefits;

  factory _$ProjectImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProjectImplFromJson(json);

  @override
  @JsonKey(name: '_id')
  final String id;
  @override
  final String title;
  @override
  final String description;
  @override
  @JsonKey()
  final String shortDesc;
  @override
  @JsonKey()
  final ProjectCategory category;
  @override
  @JsonKey()
  final String status;
  @override
  @JsonKey(defaultValue: 0)
  final double? totalPrice;
  @override
  @JsonKey(defaultValue: 0)
  final double? expectedROI;
  @override
  @JsonKey(defaultValue: 0)
  final double? availablePercentage;
  @override
  @JsonKey(defaultValue: 0)
  final double? progress;
  @override
  final String? image;
  final List<String> _potentialRisks;
  @override
  @JsonKey()
  List<String> get potentialRisks {
    if (_potentialRisks is EqualUnmodifiableListView) return _potentialRisks;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_potentialRisks);
  }

  final List<String> _keyBenefits;
  @override
  @JsonKey()
  List<String> get keyBenefits {
    if (_keyBenefits is EqualUnmodifiableListView) return _keyBenefits;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_keyBenefits);
  }

  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'Project(id: $id, title: $title, description: $description, shortDesc: $shortDesc, category: $category, status: $status, totalPrice: $totalPrice, expectedROI: $expectedROI, availablePercentage: $availablePercentage, progress: $progress, image: $image, potentialRisks: $potentialRisks, keyBenefits: $keyBenefits, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProjectImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.shortDesc, shortDesc) ||
                other.shortDesc == shortDesc) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.totalPrice, totalPrice) ||
                other.totalPrice == totalPrice) &&
            (identical(other.expectedROI, expectedROI) ||
                other.expectedROI == expectedROI) &&
            (identical(other.availablePercentage, availablePercentage) ||
                other.availablePercentage == availablePercentage) &&
            (identical(other.progress, progress) ||
                other.progress == progress) &&
            (identical(other.image, image) || other.image == image) &&
            const DeepCollectionEquality().equals(
              other._potentialRisks,
              _potentialRisks,
            ) &&
            const DeepCollectionEquality().equals(
              other._keyBenefits,
              _keyBenefits,
            ) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    title,
    description,
    shortDesc,
    category,
    status,
    totalPrice,
    expectedROI,
    availablePercentage,
    progress,
    image,
    const DeepCollectionEquality().hash(_potentialRisks),
    const DeepCollectionEquality().hash(_keyBenefits),
    createdAt,
    updatedAt,
  );

  /// Create a copy of Project
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProjectImplCopyWith<_$ProjectImpl> get copyWith =>
      __$$ProjectImplCopyWithImpl<_$ProjectImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProjectImplToJson(this);
  }
}

abstract class _Project implements Project {
  const factory _Project({
    @JsonKey(name: '_id') required final String id,
    required final String title,
    required final String description,
    final String shortDesc,
    final ProjectCategory category,
    final String status,
    @JsonKey(defaultValue: 0) final double? totalPrice,
    @JsonKey(defaultValue: 0) final double? expectedROI,
    @JsonKey(defaultValue: 0) final double? availablePercentage,
    @JsonKey(defaultValue: 0) final double? progress,
    final String? image,
    final List<String> potentialRisks,
    final List<String> keyBenefits,
    final DateTime? createdAt,
    final DateTime? updatedAt,
  }) = _$ProjectImpl;

  factory _Project.fromJson(Map<String, dynamic> json) = _$ProjectImpl.fromJson;

  @override
  @JsonKey(name: '_id')
  String get id;
  @override
  String get title;
  @override
  String get description;
  @override
  String get shortDesc;
  @override
  ProjectCategory get category;
  @override
  String get status;
  @override
  @JsonKey(defaultValue: 0)
  double? get totalPrice;
  @override
  @JsonKey(defaultValue: 0)
  double? get expectedROI;
  @override
  @JsonKey(defaultValue: 0)
  double? get availablePercentage;
  @override
  @JsonKey(defaultValue: 0)
  double? get progress;
  @override
  String? get image;
  @override
  List<String> get potentialRisks;
  @override
  List<String> get keyBenefits;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of Project
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProjectImplCopyWith<_$ProjectImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ProjectCategory _$ProjectCategoryFromJson(Map<String, dynamic> json) {
  return _ProjectCategory.fromJson(json);
}

/// @nodoc
mixin _$ProjectCategory {
  String get en => throw _privateConstructorUsedError;
  String get ar => throw _privateConstructorUsedError;

  /// Serializes this ProjectCategory to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProjectCategory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProjectCategoryCopyWith<ProjectCategory> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProjectCategoryCopyWith<$Res> {
  factory $ProjectCategoryCopyWith(
    ProjectCategory value,
    $Res Function(ProjectCategory) then,
  ) = _$ProjectCategoryCopyWithImpl<$Res, ProjectCategory>;
  @useResult
  $Res call({String en, String ar});
}

/// @nodoc
class _$ProjectCategoryCopyWithImpl<$Res, $Val extends ProjectCategory>
    implements $ProjectCategoryCopyWith<$Res> {
  _$ProjectCategoryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProjectCategory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? en = null, Object? ar = null}) {
    return _then(
      _value.copyWith(
            en: null == en
                ? _value.en
                : en // ignore: cast_nullable_to_non_nullable
                      as String,
            ar: null == ar
                ? _value.ar
                : ar // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ProjectCategoryImplCopyWith<$Res>
    implements $ProjectCategoryCopyWith<$Res> {
  factory _$$ProjectCategoryImplCopyWith(
    _$ProjectCategoryImpl value,
    $Res Function(_$ProjectCategoryImpl) then,
  ) = __$$ProjectCategoryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String en, String ar});
}

/// @nodoc
class __$$ProjectCategoryImplCopyWithImpl<$Res>
    extends _$ProjectCategoryCopyWithImpl<$Res, _$ProjectCategoryImpl>
    implements _$$ProjectCategoryImplCopyWith<$Res> {
  __$$ProjectCategoryImplCopyWithImpl(
    _$ProjectCategoryImpl _value,
    $Res Function(_$ProjectCategoryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProjectCategory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? en = null, Object? ar = null}) {
    return _then(
      _$ProjectCategoryImpl(
        en: null == en
            ? _value.en
            : en // ignore: cast_nullable_to_non_nullable
                  as String,
        ar: null == ar
            ? _value.ar
            : ar // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ProjectCategoryImpl implements _ProjectCategory {
  const _$ProjectCategoryImpl({this.en = 'General', this.ar = 'عام'});

  factory _$ProjectCategoryImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProjectCategoryImplFromJson(json);

  @override
  @JsonKey()
  final String en;
  @override
  @JsonKey()
  final String ar;

  @override
  String toString() {
    return 'ProjectCategory(en: $en, ar: $ar)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProjectCategoryImpl &&
            (identical(other.en, en) || other.en == en) &&
            (identical(other.ar, ar) || other.ar == ar));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, en, ar);

  /// Create a copy of ProjectCategory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProjectCategoryImplCopyWith<_$ProjectCategoryImpl> get copyWith =>
      __$$ProjectCategoryImplCopyWithImpl<_$ProjectCategoryImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ProjectCategoryImplToJson(this);
  }
}

abstract class _ProjectCategory implements ProjectCategory {
  const factory _ProjectCategory({final String en, final String ar}) =
      _$ProjectCategoryImpl;

  factory _ProjectCategory.fromJson(Map<String, dynamic> json) =
      _$ProjectCategoryImpl.fromJson;

  @override
  String get en;
  @override
  String get ar;

  /// Create a copy of ProjectCategory
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProjectCategoryImplCopyWith<_$ProjectCategoryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
