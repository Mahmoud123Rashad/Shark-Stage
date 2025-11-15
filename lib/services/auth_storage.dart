import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class AuthStorage {
  static const _tokenKey = 'token';
  static const _userKey = 'auth_user';

  static Future<void> saveSession({
    required String token,
    required Map<String, dynamic> user,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userKey, jsonEncode(user));
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<void> saveUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user));
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_userKey);
    if (raw == null) {
      return null;
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (_) {
      // swallow parsing errors
    }
    return null;
  }

  static Future<Map<String, String?>> getUserSummary() async {
    final stored = await getUser();
    if (stored == null) {
      return {
        'id': null,
        'email': null,
        'role': null,
        'firstName': null,
        'lastName': null,
      };
    }
    String? readString(dynamic value) =>
        value == null ? null : value.toString();

    return {
      'id': readString(stored['_id'] ?? stored['id']),
      'email': readString(stored['email']),
      'role': readString(stored['accountType'] ?? stored['role']),
      'firstName': readString(stored['firstName']),
      'lastName': readString(stored['lastName']),
    };
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }
}
// lib/services/auth_storage.dart
