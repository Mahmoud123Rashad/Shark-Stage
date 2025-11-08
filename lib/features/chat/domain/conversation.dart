import 'package:freezed_annotation/freezed_annotation.dart';

part 'conversation.freezed.dart';
part 'conversation.g.dart';

@freezed
class Conversation with _$Conversation {
  const factory Conversation({
    @JsonKey(name: '_id') required String id,
    @Default(<ChatParticipant>[]) List<ChatParticipant> participants,
    ChatMessage? lastMessage,
    DateTime? updatedAt,
  }) = _Conversation;

  factory Conversation.fromJson(Map<String, dynamic> json) =>
      _$ConversationFromJson(json);
}

@freezed
class ChatParticipant with _$ChatParticipant {
  const factory ChatParticipant({
    @JsonKey(name: '_id') required String id,
    String? firstName,
    String? lastName,
    String? email,
    String? profilePicUrl,
  }) = _ChatParticipant;

  factory ChatParticipant.fromJson(Map<String, dynamic> json) =>
      _$ChatParticipantFromJson(json);
}

@freezed
class ChatMessage with _$ChatMessage {
  const factory ChatMessage({
    @JsonKey(name: '_id') required String id,
    required String content,
    ChatParticipant? sender,
    DateTime? createdAt,
  }) = _ChatMessage;

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);
}
