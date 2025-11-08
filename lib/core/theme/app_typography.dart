import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_palette.dart';

/// Text styles inspired by the SharkStage marketing site.
final class AppTypography {
  static TextTheme lightTextTheme = _baseTextTheme(
    brightness: Brightness.light,
  );
  static TextTheme darkTextTheme = _baseTextTheme(brightness: Brightness.dark);

  static TextTheme _baseTextTheme({required Brightness brightness}) {
    final Color headingColor = brightness == Brightness.dark
        ? Colors.white
        : AppPalette.heading;
    final Color bodyColor = brightness == Brightness.dark
        ? Colors.white70
        : AppPalette.paragraph;
    final Color mutedColor = brightness == Brightness.dark
        ? Colors.white54
        : AppPalette.muted;

    final TextStyle display = GoogleFonts.poppins(
      fontWeight: FontWeight.w700,
      letterSpacing: -0.5,
      color: headingColor,
    );

    final TextStyle body = GoogleFonts.inter(
      fontWeight: FontWeight.w400,
      color: bodyColor,
      height: 1.45,
    );

    return TextTheme(
      displayLarge: display.copyWith(fontSize: 48),
      displayMedium: display.copyWith(fontSize: 40),
      displaySmall: display.copyWith(fontSize: 32),
      headlineLarge: display.copyWith(fontSize: 28),
      headlineMedium: display.copyWith(fontSize: 24),
      headlineSmall: display.copyWith(fontSize: 20),
      titleLarge: display.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
      ),
      titleMedium: display.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
      ),
      titleSmall: display.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
      bodyLarge: body.copyWith(fontSize: 16, height: 1.6),
      bodyMedium: body.copyWith(fontSize: 14, height: 1.52),
      bodySmall: body.copyWith(fontSize: 12, color: mutedColor, height: 1.48),
      labelLarge: GoogleFonts.inter(
        fontWeight: FontWeight.w600,
        fontSize: 14,
        color: Colors.white,
        letterSpacing: 0.5,
      ),
      labelMedium: GoogleFonts.inter(
        fontWeight: FontWeight.w600,
        fontSize: 12,
        color: bodyColor,
        letterSpacing: 0.5,
      ),
      labelSmall: GoogleFonts.inter(
        fontWeight: FontWeight.w600,
        fontSize: 11,
        color: mutedColor,
        letterSpacing: 0.6,
      ),
    );
  }

  static TextStyle get overline => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.1,
        color: AppPalette.muted,
        height: 1.2,
      );

  static TextStyle get chipLabel => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.6,
        color: AppPalette.heading,
      );

  static TextStyle get inputPlaceholder => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppPalette.muted,
      );
}
