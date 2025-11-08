import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists the auth token, favouring secure storage when available.
class TokenStorage {
  TokenStorage(this._secureStorage, this._preferences);

  final FlutterSecureStorage _secureStorage;
  final SharedPreferences _preferences;

  static const String _tokenKey = 'shark_token';

  Future<void> write(String token) async {
    await _secureStorage.write(key: _tokenKey, value: token);
    await _preferences.setString(_tokenKey, token);
  }

  Future<String?> read() async {
    final String? secureToken = await _secureStorage.read(key: _tokenKey);
    if (secureToken != null && secureToken.isNotEmpty) {
      return secureToken;
    }
    return _preferences.getString(_tokenKey);
  }

  Future<void> clear() async {
    await _secureStorage.delete(key: _tokenKey);
    await _preferences.remove(_tokenKey);
  }
}
