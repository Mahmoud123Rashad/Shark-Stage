import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/storage/shared_preferences_provider.dart';

class BootstrapResult {
  BootstrapResult({required this.preferences, required this.overrides});

  final SharedPreferences preferences;
  final List<Override> overrides;
}

Future<BootstrapResult> bootstrap() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  final List<Override> overrides = <Override>[
    sharedPreferencesProvider.overrideWithValue(prefs),
  ];

  return BootstrapResult(preferences: prefs, overrides: overrides);
}
