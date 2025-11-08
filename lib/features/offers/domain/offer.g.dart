// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$OfferImpl _$$OfferImplFromJson(Map<String, dynamic> json) => _$OfferImpl(
  id: json['_id'] as String,
  status: json['status'] as String,
  amount: (json['amount'] as num?)?.toDouble() ?? 0,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  project: json['project'] == null
      ? null
      : Project.fromJson(json['project'] as Map<String, dynamic>),
  offeredBy: json['offeredBy'] == null
      ? null
      : AppUser.fromJson(json['offeredBy'] as Map<String, dynamic>),
  offeredTo: json['offeredTo'] == null
      ? null
      : AppUser.fromJson(json['offeredTo'] as Map<String, dynamic>),
  terms: json['terms'] as String?,
  message: json['message'] as String?,
);

Map<String, dynamic> _$$OfferImplToJson(_$OfferImpl instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'status': instance.status,
      'amount': instance.amount,
      'createdAt': instance.createdAt?.toIso8601String(),
      'project': instance.project,
      'offeredBy': instance.offeredBy,
      'offeredTo': instance.offeredTo,
      'terms': instance.terms,
      'message': instance.message,
    };
