import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginService {
  static const String baseUrl = "https://sharkserver-production.up.railway.app";

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/auth/signin');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          data['success'] == true) {
        final prefs = await SharedPreferences.getInstance();
        if (data['token'] != null) {
          await prefs.setString('token', data['token']);
        }

        return {
          'success': true,
          'role': data['user']?['accountType']?.toLowerCase(),
          'message': data['message'],
        };
      } else {
        return {'success': false, 'message': data['message'] ?? "Login failed"};
      }
    } catch (e) {
      return {'success': false, 'message': "Error: $e"};
    }
  }
}
