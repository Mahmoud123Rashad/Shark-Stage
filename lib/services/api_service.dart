import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static late String baseUrl;

  static Future<void> init({required String baseUrl}) async {
    ApiService.baseUrl = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
  }

  static Future<Map<String, dynamic>?> post(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    print("➡️ POST $url\nBody: ${jsonEncode(body)}");

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body ?? {}),
    );

    print("⬅️ Response (${response.statusCode}): ${response.body}");

    try {
      return jsonDecode(response.body);
    } catch (_) {
      print("Failed to decode response: ${response.body}");
      return {"success": false, "message": "Invalid response format"};
    }
  }

  static Future<Map<String, dynamic>?> get(String endpoint) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    print("➡️ GET $url");
    final response = await http.get(url);
    print("⬅️ Response (${response.statusCode}): ${response.body}");

    try {
      return jsonDecode(response.body);
    } catch (_) {
      return {"success": false, "message": "Invalid response format"};
    }
  }

  static Future<Map<String, dynamic>?> put(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    print("➡️ PUT $url\nBody: ${jsonEncode(body)}");
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body ?? {}),
    );
    print("⬅️ Response (${response.statusCode}): ${response.body}");

    try {
      return jsonDecode(response.body);
    } catch (_) {
      return {"success": false, "message": "Invalid response format"};
    }
  }

  static Future<bool> delete(String endpoint) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    print("➡️ DELETE $url");
    final response = await http.delete(url);
    print("⬅️ Response (${response.statusCode}): ${response.body}");
    return response.statusCode == 200;
  }
}
