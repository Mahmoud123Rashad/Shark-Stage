import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provides a synchronously available [SharedPreferences] instance.
///
/// The actual value is supplied during app bootstrap via an override.
final Provider<SharedPreferences>
sharedPreferencesProvider = Provider<SharedPreferences>(
  (_) => throw StateError(
    'SharedPreferences not initialised. Override sharedPreferencesProvider in bootstrap().',
  ),
);
