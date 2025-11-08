import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/dio_provider.dart';
import '../../../core/network/network_exceptions.dart';
import '../domain/conversation.dart';

final Provider<ChatRepository> chatRepositoryProvider = Provider<ChatRepository>(
  (Ref ref) => ChatRepository(apiClient: ref.watch(apiClientProvider)),
);

final FutureProvider<List<Conversation>> conversationsProvider =
    FutureProvider<List<Conversation>>(
  (Ref ref) => ref.watch(chatRepositoryProvider).fetchConversations(),
);

final FutureProviderFamily<List<ChatMessage>, String> messagesProvider =
    FutureProvider.family<List<ChatMessage>, String>(
  (Ref ref, String conversationId) =>
      ref.watch(chatRepositoryProvider).fetchMessages(conversationId),
);

class ChatRepository {
  ChatRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<List<Conversation>> fetchConversations() async {
    final Response<dynamic> response =
        await _apiClient.get<dynamic>('/chat/conversations');
    final Map<String, dynamic> body = _expectJson(response);
    final List<dynamic> raw = body['conversations'] as List<dynamic>? ?? <dynamic>[];
    return raw
        .map(
          (dynamic json) => Conversation.fromJson(
            (json as Map<Object?, Object?>).cast<String, dynamic>(),
          ),
        )
        .toList();
  }

  Future<List<ChatMessage>> fetchMessages(String conversationId) async {
    final Response<dynamic> response =
        await _apiClient.get<dynamic>('/chat/$conversationId');
    final Map<String, dynamic> body = _expectJson(response);
    final List<dynamic> raw = body['messages'] as List<dynamic>? ?? <dynamic>[];
    return raw
        .map(
          (dynamic json) => ChatMessage.fromJson(
            (json as Map<Object?, Object?>).cast<String, dynamic>(),
          ),
        )
        .toList();
  }

  Future<void> sendMessage({
    required String receiverId,
    required String content,
  }) async {
    await _apiClient.post<dynamic>(
      '/chat/send',
      data: <String, dynamic>{
        'receiverId': receiverId,
        'content': content,
      },
    );
  }

  Map<String, dynamic> _expectJson(Response<dynamic> response) {
    final dynamic data = response.data;
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is String && data.isNotEmpty) {
      return jsonDecode(data) as Map<String, dynamic>;
    }
    throw const NetworkParsingException('Unexpected response payload');
  }
}

