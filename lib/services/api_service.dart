import 'dart:convert';
import 'package:http/http.dart' as http;

import 'auth_storage.dart';

class ApiService {
  static late String baseUrl;

  static Future<void> init({required String baseUrl}) async {
    ApiService.baseUrl = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
  }

  static Uri _resolve(String endpoint) {
    final sanitized =
        endpoint.startsWith('/') ? endpoint.substring(1) : endpoint;
    return Uri.parse('$baseUrl/$sanitized');
  }

  static Future<Map<String, String>> _buildHeaders({
    bool auth = false,
    Map<String, String>? headers,
  }) async {
    final result = <String, String>{
      'Content-Type': 'application/json',
      if (headers != null) ...headers,
    };

    if (auth) {
      final token = await AuthStorage.getToken();
      if (token != null && token.isNotEmpty) {
        result['Authorization'] = 'Bearer $token';
      }
    }
    return result;
  }

  static Map<String, dynamic> _parseResponse(http.Response response) {
    Map<String, dynamic> parsed;
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        parsed = Map<String, dynamic>.from(decoded);
      } else {
        parsed = {'data': decoded};
      }
    } catch (_) {
      parsed = {'message': 'Invalid response format', 'raw': response.body};
    }
    parsed.putIfAbsent('status', () => response.statusCode);
    return parsed;
  }

  static Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    bool auth = false,
    Map<String, String>? headers,
  }) async {
    final url = _resolve(endpoint);
    print("➡️ POST $url\nBody: ${jsonEncode(body)}");

    final response = await http.post(
      url,
      headers: await _buildHeaders(auth: auth, headers: headers),
      body: jsonEncode(body ?? {}),
    );

    print("⬅️ Response (${response.statusCode}): ${response.body}");
    return _parseResponse(response);
  }

  static Future<Map<String, dynamic>> get(
    String endpoint, {
    bool auth = false,
    Map<String, String>? headers,
  }) async {
    final url = _resolve(endpoint);
    print("➡️ GET $url");
    final response = await http.get(
      url,
      headers: await _buildHeaders(auth: auth, headers: headers),
    );
    print("⬅️ Response (${response.statusCode}): ${response.body}");
    return _parseResponse(response);
  }

  static Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? body,
    bool auth = false,
    Map<String, String>? headers,
  }) async {
    final url = _resolve(endpoint);
    print("➡️ PUT $url\nBody: ${jsonEncode(body)}");
    final response = await http.put(
      url,
      headers: await _buildHeaders(auth: auth, headers: headers),
      body: jsonEncode(body ?? {}),
    );
    print("⬅️ Response (${response.statusCode}): ${response.body}");
    return _parseResponse(response);
  }

  static Future<Map<String, dynamic>> patch(
    String endpoint, {
    Map<String, dynamic>? body,
    bool auth = false,
    Map<String, String>? headers,
  }) async {
    final url = _resolve(endpoint);
    print("➡️ PATCH $url\nBody: ${jsonEncode(body)}");
    final response = await http.patch(
      url,
      headers: await _buildHeaders(auth: auth, headers: headers),
      body: jsonEncode(body ?? {}),
    );
    print("⬅️ Response (${response.statusCode}): ${response.body}");
    return _parseResponse(response);
  }

  static Future<bool> delete(
    String endpoint, {
    bool auth = false,
    Map<String, String>? headers,
  }) async {
    final url = _resolve(endpoint);
    print("➡️ DELETE $url");
    final response = await http.delete(
      url,
      headers: await _buildHeaders(auth: auth, headers: headers),
    );
    print("⬅️ Response (${response.statusCode}): ${response.body}");
    return response.statusCode == 200;
  }
}
