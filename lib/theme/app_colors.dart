import 'package:flutter/material.dart';

import '../core/theme/app_palette.dart';

class AppColors {
  /// Brand tokens
  static const Color primary = AppPalette.primary;
  static const Color secondary = AppPalette.secondary;
  static const Color tertiary = AppPalette.tertiary;
  static const Color accent = AppPalette.accent;

  /// Semantics
  static const Color success = AppPalette.success;
  static const Color warning = AppPalette.warning;
  static const Color danger = AppPalette.danger;
  static const Color info = AppPalette.info;

  /// Surfaces
  static const Color background = AppPalette.background;
  static const Color surface = AppPalette.surface;
  static const Color surfaceMuted = AppPalette.surfaceMuted;
  static const Color surfaceDark = AppPalette.surfaceDark;
  static const Color card = AppPalette.card;
  static const Color soft = AppPalette.soft;

  /// Typography
  static const Color heading = AppPalette.heading;
  static const Color paragraph = AppPalette.paragraph;
  static const Color muted = AppPalette.muted;

  /// Borders & shadow
  static const Color outline = AppPalette.outline;
  static const Color outlineStrong = AppPalette.outlineStrong;
  static const Color shadow = AppPalette.shadow;

  /// Gradients
  static const LinearGradient mainGradient = AppPalette.marketingGradient;
  static const LinearGradient dashboardGradient = AppPalette.dashboardGradient;
  static const LinearGradient accentGradient = AppPalette.accentGradient;
}
