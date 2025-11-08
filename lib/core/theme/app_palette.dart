import 'package:flutter/material.dart';

/// Core color palette aligned with the SharkStage web design system.
///
/// Values mirror the Tailwind theme declared in `sharkstage/app/globals.css`.
final class AppPalette {
  /// Brand primitives
  static const Color primary = Color(0xFF3A5A92);
  static const Color secondary = Color(0xFF6FA8DC);
  static const Color tertiary = Color(0xFF8ED1FC);
  static const Color accent = Color(0xFFF2C94C);

  /// Semantic tokens
  static const Color success = Color(0xFF2A9D8F);
  static const Color warning = Color(0xFFF4A261);
  static const Color danger = Color(0xFFE76F51);
  static const Color info = Color(0xFF4C82FB);

  /// Neutral surfaces
  static const Color background = Color(0xFFF5F7FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF0F4F8);
  static const Color surfaceDark = Color(0xFF1A2233);

  /// Typography colors
  static const Color heading = Color(0xFF13294B);
  static const Color paragraph = Color(0xFF64748B);
  static const Color muted = Color(0xFF94A3B8);

  /// Utility palette
  static const Color outline = Color(0xFFE2E8F0);
  static const Color outlineStrong = Color(0xFFCBD5E1);
  static const Color soft = Color(0xFFDBE9F7);
  static const Color card = Color(0xFFFFFFFF);
  static const Color shadow = Color(0x1A0F172A);

  /// Gradients
  static const LinearGradient marketingGradient = LinearGradient(
    colors: <Color>[primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient dashboardGradient = LinearGradient(
    colors: <Color>[primary, secondary],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: <Color>[accent, secondary],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
