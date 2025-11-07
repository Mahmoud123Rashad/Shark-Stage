// lib/screens/profile/profile_service.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileService {
  static const String baseUrl = "https://sharkserver-production.up.railway.app";

  /// 🧠 جلب بيانات البروفايل
  static Future<Map<String, dynamic>?> fetchProfile(String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) return null;

      final response = await http.get(
        Uri.parse("$baseUrl/auth/me"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['user'];
      } else {
        debugPrint("❌ Failed to fetch profile: ${response.body}");
        return null;
      }
    } catch (e) {
      debugPrint("❌ Exception fetching profile: $e");
      return null;
    }
  }

  /// 📸 اختيار ورفع الصورة الشخصية
  static Future<String?> pickAndUploadImage(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return null;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return null;

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse("$baseUrl/upload/profilepic"),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(
        await http.MultipartFile.fromPath('image', pickedFile.path),
      );

      final response = await request.send();
      final resBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final json = jsonDecode(resBody);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile picture updated successfully")),
        );
        return json['profilePicUrl'];
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Upload failed: $resBody")),
        );
        return null;
      }
    } catch (e) {
      debugPrint(" Upload error: $e");
      return null;
    }
  }
}
