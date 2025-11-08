import 'package:flutter/material.dart';

/// Spatial scale used across the mobile experience to maintain rhythm.
final class AppSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double mega = 40;
}

/// Shared radius tokens mirroring the web design system.
final class AppRadius {
  static const BorderRadius pill = BorderRadius.all(Radius.circular(999));
  static const BorderRadius sm = BorderRadius.all(Radius.circular(10));
  static const BorderRadius md = BorderRadius.all(Radius.circular(16));
  static const BorderRadius lg = BorderRadius.all(Radius.circular(24));
  static const BorderRadius xl = BorderRadius.all(Radius.circular(32));
}

