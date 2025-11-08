import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as legacy_provider;
import 'package:shared_preferences/shared_preferences.dart';

import 'bootstrap.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'theme/theme_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final bootstrapResult = await bootstrap();
  final SharedPreferences prefs = bootstrapResult.preferences;
  final bool isDark = prefs.getBool('isDarkMode') ?? false;

  runApp(
    ProviderScope(
      overrides: bootstrapResult.overrides,
      child: legacy_provider.ChangeNotifierProvider(
        create: (_) => ThemeProvider(isDark ? ThemeMode.dark : ThemeMode.light),
        child: const SharkStageApp(),
      ),
    ),
  );
}

class SharkStageApp extends StatelessWidget {
  const SharkStageApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeProvider themeProvider =
        legacy_provider.Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Shark Stage',
      debugShowCheckedModeBanner: false,
      theme: themeProvider.currentTheme,
      darkTheme: themeProvider.currentTheme,
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const SplashScreen(),
    );
  }
}
