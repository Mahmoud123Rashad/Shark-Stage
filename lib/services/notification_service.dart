import 'dart:async';
import 'api_service.dart';
import 'chat_service.dart';

class NotificationService {
  static final StreamController<Map<String, dynamic>> _notificationStreamController =
      StreamController<Map<String, dynamic>>.broadcast();

  static Stream<Map<String, dynamic>> get notificationStream =>
      _notificationStreamController.stream;

  // Initialize Socket.IO listener for notifications
  static Future<void> initializeNotificationListener() async {
    await ChatService.initializeSocket();
    // The socket is already initialized in ChatService, we just need to listen
    // We'll add the listener in ChatService or create a separate socket connection
    // For now, we'll use a callback approach
  }

  // Call this when a notification is received via Socket.IO
  static void onNotificationReceived(Map<String, dynamic> notification) {
    _notificationStreamController.add(notification);
  }

  // 🔹 جلب جميع الإشعارات
  static Future<List<dynamic>> getNotifications() async {
    try {
      final response = await ApiService.get(
        'notifications/user',
        auth: true,
      );

      if (response['status'] == 200 && response['success'] == true) {
        return response['userNotifications'] as List<dynamic>? ?? [];
      } else {
        print("❌ Failed to load notifications: ${response['status']}");
        return [];
      }
    } catch (e) {
      print("🔥 Error fetching notifications: $e");
      return [];
    }
  }

  // 🔹 تعليم إشعار كمقروء
  static Future<bool> markAsRead(String id) async {
    try {
      final response = await ApiService.patch(
        'notifications/read/$id',
        auth: true,
      );

      final statusCode = response['status'] as int? ?? 500;
      return statusCode == 200 && response['success'] == true;
    } catch (e) {
      print("🔥 Error marking notification as read: $e");
      return false;
    }
  }

  // 🔹 الحصول على عدد الاشعارات غير المقروءة
  static Future<int> getUnreadCount() async {
    try {
      final notifications = await getNotifications();
      return notifications.where((n) => n['isRead'] != true).length;
    } catch (e) {
      print("🔥 Error getting unread count: $e");
      return 0;
    }
  }
}
