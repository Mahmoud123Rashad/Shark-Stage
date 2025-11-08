// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProjectImpl _$$ProjectImplFromJson(Map<String, dynamic> json) =>
    _$ProjectImpl(
      id: json['_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      shortDesc: json['shortDesc'] as String? ?? '',
      category: json['category'] == null
          ? const ProjectCategory()
          : ProjectCategory.fromJson(json['category'] as Map<String, dynamic>),
      status: json['status'] as String? ?? 'active',
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0,
      expectedROI: (json['expectedROI'] as num?)?.toDouble() ?? 0,
      availablePercentage:
          (json['availablePercentage'] as num?)?.toDouble() ?? 0,
      progress: (json['progress'] as num?)?.toDouble() ?? 0,
      image: json['image'] as String?,
      potentialRisks:
          (json['potentialRisks'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      keyBenefits:
          (json['keyBenefits'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$ProjectImplToJson(_$ProjectImpl instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'shortDesc': instance.shortDesc,
      'category': instance.category,
      'status': instance.status,
      'totalPrice': instance.totalPrice,
      'expectedROI': instance.expectedROI,
      'availablePercentage': instance.availablePercentage,
      'progress': instance.progress,
      'image': instance.image,
      'potentialRisks': instance.potentialRisks,
      'keyBenefits': instance.keyBenefits,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

_$ProjectCategoryImpl _$$ProjectCategoryImplFromJson(
  Map<String, dynamic> json,
) => _$ProjectCategoryImpl(
  en: json['en'] as String? ?? 'General',
  ar: json['ar'] as String? ?? 'عام',
);

Map<String, dynamic> _$$ProjectCategoryImplToJson(
  _$ProjectCategoryImpl instance,
) => <String, dynamic>{'en': instance.en, 'ar': instance.ar};
