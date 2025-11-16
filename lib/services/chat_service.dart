import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'api_service.dart';
import 'auth_storage.dart';
import 'notification_service.dart';

class ChatService {
  static IO.Socket? _socket;
  static bool _isConnected = false;
  static final Map<String, StreamController<Map<String, dynamic>>> _messageStreams = {};

  // Initialize Socket.IO connection
  static Future<void> initializeSocket() async {
    if (_socket != null && _isConnected) return;

    try {
      final token = await AuthStorage.getToken();
      if (token == null || token.isEmpty) {
        print("⚠️ No token found for socket connection");
        return;
      }

      final baseUrl = ApiService.baseUrl;
      // Socket.IO needs the base URL
      final socketUrl = baseUrl;

      _socket = IO.io(
        socketUrl,
        IO.OptionBuilder()
            .setTransports(['websocket', 'polling'])
            .setAuth({'token': token})
            .enableAutoConnect()
            .build(),
      );

      _socket!.onConnect((_) {
        print("✅ Socket connected");
        _isConnected = true;
      });

      _socket!.onDisconnect((_) {
        print("❌ Socket disconnected");
        _isConnected = false;
      });

      _socket!.onError((error) {
        print("🔥 Socket error: $error");
        _isConnected = false;
      });

      _socket!.onConnectError((error) {
        print("🔥 Socket connection error: $error");
        _isConnected = false;
      });

      // Listen for incoming messages
      _socket!.on('receive_message', (data) {
        if (data is Map<String, dynamic>) {
          final conversationId = data['conversationId']?.toString();
          if (conversationId != null && _messageStreams.containsKey(conversationId)) {
            _messageStreams[conversationId]!.add(data);
          }
        }
      });

      // Listen for notifications
      _socket!.on('notification', (data) {
        if (data is Map<String, dynamic>) {
          NotificationService.onNotificationReceived(data);
        }
      });
    } catch (e) {
      print("🔥 Error initializing socket: $e");
    }
  }

  // Disconnect Socket.IO
  static void disconnectSocket() {
    if (_socket != null) {
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
      _isConnected = false;
    }
    _messageStreams.clear();
  }

  // Join a conversation room
  static void joinConversation(String conversationId) {
    if (_socket != null && _isConnected) {
      _socket!.emit('join_conversation', conversationId);
    }
  }

  // Get message stream for a conversation
  static Stream<Map<String, dynamic>>? getMessageStream(String conversationId) {
    if (!_messageStreams.containsKey(conversationId)) {
      _messageStreams[conversationId] = StreamController<Map<String, dynamic>>.broadcast();
    }
    return _messageStreams[conversationId]!.stream;
  }

  // Get all conversations
  static Future<List<dynamic>> getConversations() async {
    try {
      final response = await ApiService.get(
        'chat/conversations',
        auth: true,
      );

      if (response['status'] == 201 && response['success'] == true) {
        return response['conversations'] as List<dynamic>? ?? [];
      } else {
        print("❌ Failed to load conversations: ${response['status']}");
        return [];
      }
    } catch (e) {
      print("🔥 Error fetching conversations: $e");
      return [];
    }
  }

  // Get messages for a conversation
  static Future<List<dynamic>> getMessages(String conversationId) async {
    try {
      final response = await ApiService.get(
        'chat/$conversationId',
        auth: true,
      );

      if (response['status'] == 201 && response['success'] == true) {
        return response['messages'] as List<dynamic>? ?? [];
      } else {
        print("❌ Failed to load messages: ${response['status']}");
        return [];
      }
    } catch (e) {
      print("🔥 Error fetching messages: $e");
      return [];
    }
  }

  // Send a message
  static Future<Map<String, dynamic>?> sendMessage(String receiverId, String content) async {
    try {
      final response = await ApiService.post(
        'chat/send',
        auth: true,
        body: {
          'receiverId': receiverId,
          'content': content,
        },
      );

      if (response['status'] == 201 && response['success'] == true) {
        return response;
      } else {
        print("❌ Failed to send message: ${response['status']}");
        return null;
      }
    } catch (e) {
      print("🔥 Error sending message: $e");
      return null;
    }
  }

  // Get other participant from conversation
  static Map<String, dynamic>? getOtherParticipant(
    Map<String, dynamic> conversation,
    String currentUserId,
  ) {
    final participants = conversation['participants'] as List<dynamic>? ?? [];
    for (final participant in participants) {
      if (participant is Map<String, dynamic>) {
        final id = participant['_id']?.toString() ?? participant['id']?.toString();
        if (id != null && id != currentUserId) {
          return participant;
        }
      }
    }
    return null;
  }
}

