import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'shared_preferences_provider.dart';
import 'token_storage.dart';

/// Lazily constructs a [TokenStorage] using secure storage plus shared preferences.
final Provider<FlutterSecureStorage> secureStorageProvider =
    Provider<FlutterSecureStorage>(
      (_) => const FlutterSecureStorage(
        aOptions: AndroidOptions(encryptedSharedPreferences: true),
        iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
        mOptions: MacOsOptions(
          accessibility: KeychainAccessibility.first_unlock,
        ),
      ),
    );

final Provider<TokenStorage> tokenStorageProvider = Provider<TokenStorage>((
  Ref ref,
) {
  final FlutterSecureStorage secureStorage = ref.watch(secureStorageProvider);
  final SharedPreferences preferences = ref.watch(sharedPreferencesProvider);
  return TokenStorage(secureStorage, preferences);
});
