import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static late String baseUrl;

  static Future<void> init({required String baseUrl}) async {
    ApiService.baseUrl = baseUrl;
  }

  static Future<Map<String, dynamic>?> post(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body ?? {}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      print("POST $endpoint failed: ${response.body}");
      return null;
    }
  }

  static Future<Map<String, dynamic>?> get(String endpoint) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print("GET $endpoint failed: ${response.body}");
      return null;
    }
  }

  static Future<Map<String, dynamic>?> put(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body ?? {}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print("PUT $endpoint failed: ${response.body}");
      return null;
    }
  }

  static Future<bool> delete(String endpoint) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    final response = await http.delete(url);
    return response.statusCode == 200;
  }
}
