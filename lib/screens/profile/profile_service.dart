// lib/screens/profile/profile_service.dart
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import '../../services/api_service.dart';
import '../../services/auth_storage.dart';

class ProfileService {
  /// 🧠 جلب بيانات البروفايل
  static Future<Map<String, dynamic>?> fetchProfile() async {
    try {
      final response = await ApiService.get('auth/me', auth: true);
      debugPrint("Profile fetch response: $response");
      if ((response['status'] == 200 || response['status'] == 201) &&
          response['user'] is Map<String, dynamic>) {
        final user = Map<String, dynamic>.from(
          response['user'] as Map<String, dynamic>,
        );
        debugPrint("User data: $user");
        debugPrint("Profile pic URL from API: ${user['profilePicUrl']}");
        await AuthStorage.saveUser(user);
        return user;
      }
      debugPrint("❌ Failed to fetch profile: ${response['message']}");
      return null;
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

    final result = await uploadProfileImage(File(pickedFile.path));
    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile picture updated successfully")),
      );
      return result['imageUrl']?.toString();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result['message'] ?? "Upload failed")),
    );
    return null;
  }

  static Future<Map<String, dynamic>> uploadProfileImage(File image) async {
    final token = await AuthStorage.getToken();
    if (token == null || token.isEmpty) {
      return {'success': false, 'message': 'Not authenticated'};
    }

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiService.baseUrl}/auth/upload-profile-picture'),
      );
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(
        await http.MultipartFile.fromPath('profilePicUrl', image.path),
      );

      final response = await request.send();
      final body = await response.stream.bytesToString();
      Map<String, dynamic> parsed;
      try {
        parsed = jsonDecode(body) as Map<String, dynamic>;
      } catch (_) {
        parsed = {'message': 'Invalid response format', 'raw': body};
      }
      parsed['status'] = response.statusCode;
      if (response.statusCode == 200 && parsed['imageUrl'] != null) {
        // Ensure full URL if relative
        String imageUrl = parsed['imageUrl'];
        if (!imageUrl.startsWith('http')) {
          imageUrl = '${ApiService.baseUrl}/$imageUrl'.replaceAll('//', '/');
        }
        final user = await AuthStorage.getUser() ?? {};
        user['profilePicUrl'] = imageUrl;
        await AuthStorage.saveUser(user);
        parsed['imageUrl'] = imageUrl;
        parsed['success'] = true;
      } else {
        parsed['success'] = false;
      }
      return parsed;
    } catch (e) {
      return {'success': false, 'message': 'Upload error: $e'};
    }
  }
}

// lib/screens/profile/profile_service.dart
