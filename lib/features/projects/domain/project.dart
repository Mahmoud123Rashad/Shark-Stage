import 'package:freezed_annotation/freezed_annotation.dart';

part 'project.freezed.dart';
part 'project.g.dart';

@freezed
class Project with _$Project {
  const factory Project({
    @JsonKey(name: '_id') required String id,
    required String title,
    required String description,
    @Default('') String shortDesc,
    @Default(ProjectCategory()) ProjectCategory category,
    @Default('active') String status,
    @JsonKey(defaultValue: 0) double? totalPrice,
    @JsonKey(defaultValue: 0) double? expectedROI,
    @JsonKey(defaultValue: 0) double? availablePercentage,
    @JsonKey(defaultValue: 0) double? progress,
    String? image,
    @Default(<String>[]) List<String> potentialRisks,
    @Default(<String>[]) List<String> keyBenefits,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Project;

  factory Project.fromJson(Map<String, dynamic> json) =>
      _$ProjectFromJson(json);
}

@freezed
class ProjectCategory with _$ProjectCategory {
  const factory ProjectCategory({
    @Default('General') String en,
    @Default('عام') String ar,
  }) = _ProjectCategory;

  factory ProjectCategory.fromJson(Map<String, dynamic> json) =>
      _$ProjectCategoryFromJson(json);
}
