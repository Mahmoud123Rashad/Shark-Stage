import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF3A5A92);
  static const Color secondary = Color(0xFF6FA8DC);
  static const Color button = Color(0xFFF2C94C);

  static const Color background = Color(0xFFF5F5F5);
  static const Color heading = Color(0xFF13294B);
  static const Color paragraph = Color(0xFF7F8C8D);
  static const Color soft = Color(0xFFDBE9F7);

  static const Color card = Color(0xFFFFFFFF);
  static const Color shadow = Color(0x33000000); 

  static const LinearGradient mainGradient = LinearGradient(
    colors: [
      Color(0xFF3A5A92), 
      Color(0xFF6FA8DC), 
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static Color? get cardBackground => null;
}
