import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/splash_screen.dart';
import 'theme/theme_provider.dart';
import 'services/api_service.dart';

const _defaultApiBase = 'https://sharkserver-production.up.railway.app';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تحميل إعدادات الثيم من SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  final isDark = prefs.getBool('isDarkMode') ?? false;

  // تهيئة API Service مع مراعاة قيم dart-define
  const runtimeApiBase =
      String.fromEnvironment('SHARK_API_BASE', defaultValue: _defaultApiBase);
  await ApiService.init(baseUrl: runtimeApiBase.trim().isEmpty ? _defaultApiBase : runtimeApiBase);

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(
        isDark ? ThemeMode.dark : ThemeMode.light,
      ),
      child: const SharkTankApp(),
    ),
  );
}

class SharkTankApp extends StatelessWidget {
  const SharkTankApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Shark Stage',
          debugShowCheckedModeBanner: false,
          theme: themeProvider.lightTheme,
          darkTheme: themeProvider.darkTheme,
          themeMode: themeProvider.isDarkMode
              ? ThemeMode.dark
              : ThemeMode.light,
          home: const SplashScreen(),
        );
      },
    );
  }
}
