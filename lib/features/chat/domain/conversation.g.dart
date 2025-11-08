// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ConversationImpl _$$ConversationImplFromJson(Map<String, dynamic> json) =>
    _$ConversationImpl(
      id: json['_id'] as String,
      participants:
          (json['participants'] as List<dynamic>?)
              ?.map((e) => ChatParticipant.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <ChatParticipant>[],
      lastMessage: json['lastMessage'] == null
          ? null
          : ChatMessage.fromJson(json['lastMessage'] as Map<String, dynamic>),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$ConversationImplToJson(_$ConversationImpl instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'participants': instance.participants,
      'lastMessage': instance.lastMessage,
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

_$ChatParticipantImpl _$$ChatParticipantImplFromJson(
  Map<String, dynamic> json,
) => _$ChatParticipantImpl(
  id: json['_id'] as String,
  firstName: json['firstName'] as String?,
  lastName: json['lastName'] as String?,
  email: json['email'] as String?,
  profilePicUrl: json['profilePicUrl'] as String?,
);

Map<String, dynamic> _$$ChatParticipantImplToJson(
  _$ChatParticipantImpl instance,
) => <String, dynamic>{
  '_id': instance.id,
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'email': instance.email,
  'profilePicUrl': instance.profilePicUrl,
};

_$ChatMessageImpl _$$ChatMessageImplFromJson(Map<String, dynamic> json) =>
    _$ChatMessageImpl(
      id: json['_id'] as String,
      content: json['content'] as String,
      sender: json['sender'] == null
          ? null
          : ChatParticipant.fromJson(json['sender'] as Map<String, dynamic>),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$ChatMessageImplToJson(_$ChatMessageImpl instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'content': instance.content,
      'sender': instance.sender,
      'createdAt': instance.createdAt?.toIso8601String(),
    };
