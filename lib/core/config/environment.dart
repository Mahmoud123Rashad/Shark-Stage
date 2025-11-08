import 'package:flutter/foundation.dart';

/// Centralised environment configuration used by the Flutter client.
///
/// Values default to local development endpoints but can be overridden
/// by passing `--dart-define` flags (e.g. `flutter run --dart-define SHARK_API_BASE=https://api.example.com`).
final class EnvironmentConfig {
  EnvironmentConfig._();

  static String? _apiBaseUrl;
  static String? _socketBaseUrl;
  static String? _webBaseUrl;
  static String? _googleClientId;
  static String? _googleServerClientId;
  static String? _googleIosClientId;

  static String get apiBaseUrl {
    if (_apiBaseUrl != null) return _apiBaseUrl!;

    const definedValue = String.fromEnvironment('SHARK_API_BASE');
    if (definedValue.isNotEmpty) {
      _apiBaseUrl = definedValue;
      return _apiBaseUrl!;
    }

    _apiBaseUrl = _defaultApiBaseUrl;
    return _apiBaseUrl!;
  }

  static String get socketBaseUrl {
    if (_socketBaseUrl != null) return _socketBaseUrl!;

    const definedValue = String.fromEnvironment('SHARK_SOCKET_BASE');
    if (definedValue.isNotEmpty) {
      _socketBaseUrl = definedValue;
      return _socketBaseUrl!;
    }

    _socketBaseUrl = apiBaseUrl;
    return _socketBaseUrl!;
  }

  static String get webBaseUrl {
    if (_webBaseUrl != null) return _webBaseUrl!;

    const definedValue = String.fromEnvironment('SHARK_WEB_BASE');
    if (definedValue.isNotEmpty) {
      _webBaseUrl = definedValue;
      return _webBaseUrl!;
    }

    _webBaseUrl = 'http://localhost:3000';
    return _webBaseUrl!;
  }

  static String get googleClientId {
    if (_googleClientId != null) return _googleClientId!;

    const definedValue = String.fromEnvironment('SHARK_GOOGLE_CLIENT_ID');
    if (definedValue.isNotEmpty) {
      _googleClientId = definedValue;
      return _googleClientId!;
    }

    _googleClientId = '';
    return _googleClientId!;
  }

  static String get googleServerClientId {
    if (_googleServerClientId != null) return _googleServerClientId!;

    const definedValue =
        String.fromEnvironment('SHARK_GOOGLE_SERVER_CLIENT_ID');
    if (definedValue.isNotEmpty) {
      _googleServerClientId = definedValue;
      return _googleServerClientId!;
    }

    _googleServerClientId = '';
    return _googleServerClientId!;
  }

  static String get googleIosClientId {
    if (_googleIosClientId != null) return _googleIosClientId!;

    const definedValue = String.fromEnvironment('SHARK_GOOGLE_IOS_CLIENT_ID');
    if (definedValue.isNotEmpty) {
      _googleIosClientId = definedValue;
      return _googleIosClientId!;
    }

    _googleIosClientId = googleClientId;
    return _googleIosClientId!;
  }

  static Uri get apiBaseUri => Uri.parse(apiBaseUrl);
  static Uri get socketBaseUri => Uri.parse(socketBaseUrl);
  static Uri get webBaseUri => Uri.parse(webBaseUrl);

  static String get _defaultApiBaseUrl {
    if (kIsWeb) return 'http://localhost:5000';

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:5000';
      case TargetPlatform.iOS:
        return 'http://127.0.0.1:5000';
      default:
        return 'http://localhost:5000';
    }
  }
}
