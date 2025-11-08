import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_palette.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// Factory methods for application-wide [ThemeData].
final class AppTheme {
  static ThemeData light() {
    final ColorScheme scheme =
        ColorScheme.fromSeed(
          seedColor: AppPalette.primary,
          brightness: Brightness.light,
        ).copyWith(
          primary: AppPalette.primary,
          secondary: AppPalette.secondary,
          surface: Colors.white,
          onSurface: AppPalette.heading,
          tertiary: AppPalette.accent,
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppPalette.background,
      textTheme: AppTypography.lightTextTheme,
      fontFamily: GoogleFonts.poppins().fontFamily,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppPalette.heading,
        titleTextStyle: AppTypography.lightTextTheme.titleLarge?.copyWith(
          color: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 8,
        shadowColor: AppPalette.shadow,
        margin: const EdgeInsets.all(AppSpacing.md),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.lg),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppPalette.soft,
        border: OutlineInputBorder(
          borderRadius: AppRadius.md,
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppPalette.accent,
          foregroundColor: AppPalette.heading,
          textStyle: AppTypography.lightTextTheme.labelLarge,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.sm,
          ),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.md),
          shadowColor: AppPalette.shadow,
        ),
      ),
      extensions: <ThemeExtension<dynamic>>[
        _GradientExtension(AppPalette.marketingGradient),
      ],
    );
  }

  static ThemeData dark() {
    final ColorScheme scheme =
        ColorScheme.fromSeed(
          seedColor: AppPalette.primary,
          brightness: Brightness.dark,
        ).copyWith(
          primary: AppPalette.primary,
          secondary: AppPalette.secondary,
          surface: const Color(0xFF101623),
          onSurface: Colors.white,
          tertiary: AppPalette.accent,
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: const Color(0xFF0A0A0A),
      textTheme: AppTypography.darkTextTheme,
      fontFamily: GoogleFonts.poppins().fontFamily,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        titleTextStyle: AppTypography.darkTextTheme.titleLarge?.copyWith(
          color: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 8,
        shadowColor: Colors.black.withValues(alpha: 0.4),
        margin: const EdgeInsets.all(AppSpacing.md),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.lg),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.06),
        border: OutlineInputBorder(
          borderRadius: AppRadius.md,
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppPalette.accent,
          foregroundColor: AppPalette.heading,
          textStyle: AppTypography.darkTextTheme.labelLarge,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.sm,
          ),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.md),
          shadowColor: Colors.black.withValues(alpha: 0.4),
        ),
      ),
      extensions: <ThemeExtension<dynamic>>[
        _GradientExtension(AppPalette.dashboardGradient),
      ],
    );
  }
}

/// Exposes gradient theming aligned with marketing materials.
class _GradientExtension extends ThemeExtension<_GradientExtension> {
  const _GradientExtension(this.gradient);

  final LinearGradient gradient;

  @override
  ThemeExtension<_GradientExtension> copyWith({LinearGradient? gradient}) {
    return _GradientExtension(gradient ?? this.gradient);
  }

  @override
  ThemeExtension<_GradientExtension> lerp(
    ThemeExtension<_GradientExtension>? other,
    double t,
  ) {
    if (other is! _GradientExtension) return this;
    return _GradientExtension(
      LinearGradient.lerp(gradient, other.gradient, t) ?? gradient,
    );
  }
}
