import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/theme/app_theme.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeProvider(ThemeMode initialMode)
    : _isDarkMode = initialMode == ThemeMode.dark;

  bool _isDarkMode;
  bool get isDarkMode => _isDarkMode;

  ThemeData get currentTheme =>
      _isDarkMode ? AppTheme.dark() : AppTheme.light();

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }
}
