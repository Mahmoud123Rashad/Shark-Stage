import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EditProfileService {
  static const String baseUrl = "https://sharkserver-production.up.railway.app";

  static Future<Map<String, dynamic>?> updateProfile({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    File? image,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) return {'error': 'Token not found'};

      final uri = Uri.parse("$baseUrl/auth/update");
      var request = http.MultipartRequest('PUT', uri);

      request.fields['firstName'] = firstName;
      request.fields['lastName'] = lastName;
      request.fields['email'] = email;
      request.fields['phone'] = phone;

      if (image != null) {
        request.files.add(await http.MultipartFile.fromPath('image', image.path));
      }

      request.headers['Authorization'] = 'Bearer $token';

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final updatedUser = data['user'] ?? data;

        await prefs.setString('firstName', updatedUser['firstName'] ?? '');
        await prefs.setString('lastName', updatedUser['lastName'] ?? '');
        await prefs.setString('email', updatedUser['email'] ?? '');
        await prefs.setString('phone', updatedUser['phone'] ?? '');

        return updatedUser;
      } else {
        final data = jsonDecode(response.body);
        return {'error': data['message'] ?? 'Failed to update profile'};
      }
    } catch (e) {
      return {'error': 'Error occurred while updating profile: $e'};
    }
  }
}
