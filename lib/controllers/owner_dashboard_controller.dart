import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/api_service.dart'; // افترض وجود هذا الملف

// نموذج البيانات (Model)
class Project {
  final String id;
  final String title;
  final String status;
  final double progress; // أضفنا progress للاستخدام في الـ Card

  Project({required this.id, required this.title, required this.status, this.progress = 0.0});

  factory Project.fromJson(Map<String, dynamic> json) {
    // ⚠️ يجب التأكد من أسماء الحقول حسب رد السيرفر
    return Project(
      id: json['_id'],
      title: json['title'],
      status: json['status'] ?? 'Unknown', 
      // مثال: قد تحتاج لحساب نسبة التقدم هنا
      progress: 0.5, 
    );
  }
}

class OwnerDashboardController {
  // ⚠️ يجب استبدال هذا بمعرف المستخدم الحقيقي بعد تسجيل الدخول
  final String ownerId = "672a9f6d239dabc92b4d31f9"; 
  
  // دالة جلب قائمة المشاريع من المسار الجديد
  Future<List<Project>> fetchOwnerProjects() async {
    final url = Uri.parse("${ApiService.baseUrl}/projects/owner/$ownerId");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> projectsJson = jsonDecode(response.body);
        return projectsJson.map((json) => Project.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load projects: Status ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching owner projects: $e');
      throw Exception('Network or parsing error: $e');
    }
  }

  // دالة جلب الإحصائيات (وهمية حالياً، تتطلب مسار API منفصل)
  Future<Map<String, String>> fetchStats() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return {
      "Projects": "12",
      "Earnings": "₤ 8,420",
      "NewOrders": "5",
      "Clients": "32",
    };
  }
}