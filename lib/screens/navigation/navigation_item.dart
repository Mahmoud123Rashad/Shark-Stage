import 'package:flutter/material.dart';

/// Immutable configuration for each bottom navigation destination.
class NavigationItem {
  const NavigationItem({
    required this.label,
    required this.icon,
    required this.builder,
    this.activeIcon,
  });

  final String label;
  final IconData icon;
  final IconData? activeIcon;
  final WidgetBuilder builder;
}

