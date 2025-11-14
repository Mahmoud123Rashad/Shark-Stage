import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'services/api_service.dart';
import 'theme/theme_provider.dart';
import 'screens/login/login_screen.dart';
import 'screens/splash_screen.dart';

const _defaultApiBase = 'https://sharkserver-production.up.railway.app';
final GlobalKey<NavigatorState> _appNavigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final isDark = prefs.getBool('isDarkMode') ?? false;

  const runtimeApiBase = String.fromEnvironment(
    'SHARK_API_BASE',
    defaultValue: _defaultApiBase,
  );
  final resolvedBase = runtimeApiBase.trim().isEmpty
      ? _defaultApiBase
      : runtimeApiBase;

  await ApiService.init(
    baseUrl: resolvedBase,
    onUnauthorized: () async {
      final context = _appNavigatorKey.currentContext;
      if (context != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Your session has expired. Please log in again.'),
          ),
        );
      }
      _appNavigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    },
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(isDark ? ThemeMode.dark : ThemeMode.light),
      child: SharkTankApp(navigatorKey: _appNavigatorKey),
    ),
  );
}

class SharkTankApp extends StatelessWidget {
  const SharkTankApp({super.key, required this.navigatorKey});

  final GlobalKey<NavigatorState> navigatorKey;

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Shark Stage',
          debugShowCheckedModeBanner: false,
          navigatorKey: navigatorKey,
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


// NovaEdge Solutions is a forward-thinking technology company dedicated to helping businesses transform their digital presence and achieve sustainable growth.
// We specialize in creating modern, scalable, and user-focused solutions — from custom software and mobile applications to data-driven business intelligence and cloud integration.

// Our mission is to bridge innovation with simplicity, enabling organizations to adapt quickly in a rapidly changing digital world.
// With a passionate team of experts, we focus on delivering measurable results, maintaining transparency, and building long-term partnerships with our clients