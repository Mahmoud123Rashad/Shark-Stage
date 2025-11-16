import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

import 'auth_storage.dart';

class ApiService {
  static late String baseUrl;
  static Future<void> Function()? _onUnauthorized;
  static bool _isHandlingUnauthorized = false;

  static Future<void> init({
    required String baseUrl,
    Future<void> Function()? onUnauthorized,
  }) async {
    ApiService.baseUrl = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    _onUnauthorized = onUnauthorized;
  }

  static Uri _resolve(String endpoint) {
    final sanitized = endpoint.startsWith('/')
        ? endpoint.substring(1)
        : endpoint;
    return Uri.parse('$baseUrl/$sanitized');
  }

  static Future<Map<String, String>> _buildHeaders({
    bool auth = false,
    Map<String, String>? headers,
    bool jsonContentType = true,
  }) async {
    final result = <String, String>{
      if (jsonContentType) 'Content-Type': 'application/json',
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
    _maybeHandleUnauthorized(response.statusCode);
    return _parseResponse(response);
  }

  static Future<Map<String, dynamic>> get(
    String endpoint, {
    bool auth = false,
    Map<String, String>? headers,
  }) async {
    final url = _resolve(endpoint);
    print("➡️ GET $url");
    http.Response response;
    try {
      response = await http
          .get(
            url,
            headers: await _buildHeaders(auth: auth, headers: headers),
          )
          .timeout(const Duration(seconds: 12));
    } on TimeoutException {
      print("⏳ GET timeout for $url");
      return {
        'status': 408,
        'message': 'Request timeout',
      };
    }
    print("⬅️ Response (${response.statusCode}): ${response.body}");
    _maybeHandleUnauthorized(response.statusCode);
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
    _maybeHandleUnauthorized(response.statusCode);
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
    _maybeHandleUnauthorized(response.statusCode);
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
    _maybeHandleUnauthorized(response.statusCode);
    return response.statusCode == 200;
  }

  static Future<Map<String, dynamic>> postMultipart(
    String endpoint, {
    Map<String, String>? fields,
    Map<String, File>? files,
    bool auth = false,
    Map<String, String>? headers,
  }) async {
    final url = _resolve(endpoint);
    print("➡️ POST (multipart) $url");

    final request = http.MultipartRequest('POST', url);
    request.headers.addAll(
      await _buildHeaders(
        auth: auth,
        headers: headers,
        jsonContentType: false,
      ),
    );

    if (fields != null && fields.isNotEmpty) {
      request.fields.addAll(fields);
    }

    if (files != null && files.isNotEmpty) {
      for (final entry in files.entries) {
        final file = entry.value;
        if (file.path.isEmpty || !file.existsSync()) continue;
        final mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';
        request.files.add(
          await http.MultipartFile.fromPath(
            entry.key,
            file.path,
            contentType: MediaType.parse(mimeType),
          ),
        );
      }
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    print("⬅️ Response (${response.statusCode}): ${response.body}");
    _maybeHandleUnauthorized(response.statusCode);
    return _parseResponse(response);
  }

  static Future<Map<String, dynamic>> putMultipart(
    String endpoint, {
    Map<String, String>? fields,
    Map<String, File>? files,
    bool auth = false,
    Map<String, String>? headers,
  }) async {
    final url = _resolve(endpoint);
    print("➡️ PUT (multipart) $url");

    final request = http.MultipartRequest('PUT', url);
    request.headers.addAll(
      await _buildHeaders(
        auth: auth,
        headers: headers,
        jsonContentType: false,
      ),
    );

    if (fields != null && fields.isNotEmpty) {
      request.fields.addAll(fields);
    }

    if (files != null && files.isNotEmpty) {
      for (final entry in files.entries) {
        final file = entry.value;
        if (file.path.isEmpty || !file.existsSync()) continue;
        final mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';
        request.files.add(
          await http.MultipartFile.fromPath(
            entry.key,
            file.path,
            contentType: MediaType.parse(mimeType),
          ),
        );
      }
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    print("⬅️ Response (${response.statusCode}): ${response.body}");
    _maybeHandleUnauthorized(response.statusCode);
    return _parseResponse(response);
  }

  static void _maybeHandleUnauthorized(int statusCode) {
    if (statusCode == 401 || statusCode == 403) {
      unawaited(_handleUnauthorized());
    }
  }

  static Future<void> _handleUnauthorized() async {
    if (_isHandlingUnauthorized) return;
    _isHandlingUnauthorized = true;
    try {
      await AuthStorage.clear();
      final callback = _onUnauthorized;
      if (callback != null) {
        await callback();
      }
    } finally {
      _isHandlingUnauthorized = false;
    }
  }
}

