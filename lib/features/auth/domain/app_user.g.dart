// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AppUserImpl _$$AppUserImplFromJson(Map<String, dynamic> json) =>
    _$AppUserImpl(
      id: json['_id'] as String,
      email: json['email'] as String? ?? '',
      accountType: json['accountType'] as String? ?? 'investor',
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      profilePicUrl: json['profilePicUrl'] as String?,
      company: json['company'] as String?,
      phone: json['phone'] as String?,
      bio: json['bio'] as String?,
    );

Map<String, dynamic> _$$AppUserImplToJson(_$AppUserImpl instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'email': instance.email,
      'accountType': instance.accountType,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'profilePicUrl': instance.profilePicUrl,
      'company': instance.company,
      'phone': instance.phone,
      'bio': instance.bio,
    };
