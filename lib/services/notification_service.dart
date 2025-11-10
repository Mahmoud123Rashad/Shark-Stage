import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  final String baseUrl = "https://sharkserver-production.up.railway.app";

  // 🔹 جلب جميع الإشعارات
  Future<List<dynamic>> getNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        print("⚠️ No token found");
        return [];
      }

      final response = await http.get(
        Uri.parse("$baseUrl/notifications"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['notifications'] ?? [];
      } else {
        print("❌ Failed to load notifications: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("🔥 Error fetching notifications: $e");
      return [];
    }
  }

  // 🔹 تعليم إشعار كمقروء
  Future<bool> markAsRead(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) return false;

      final response = await http.put(
        Uri.parse("$baseUrl/notifications/$id/read"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print("🔥 Error marking notification as read: $e");
      return false;
    }
  }
}
