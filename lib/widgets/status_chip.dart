import 'package:flutter/material.dart';

import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';
import '../theme/app_colors.dart';

enum StatusTone { neutral, primary, success, warning, danger, info }

/// Pill style chip used across project, offer, and messaging flows.
class StatusChip extends StatelessWidget {
  const StatusChip({
    super.key,
    required this.label,
    this.tone = StatusTone.neutral,
    this.icon,
    this.onTap,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: AppSpacing.xs,
    ),
  });

  final String label;
  final StatusTone tone;
  final IconData? icon;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final _ChipColors resolved = _resolveColors();
    final Widget chipBody = Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (icon != null)
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.xs),
            child: Icon(
              icon,
              size: 16,
              color: resolved.foreground,
            ),
          ),
        Text(
          label,
          style: AppTypography.chipLabel.copyWith(color: resolved.foreground),
        ),
      ],
    );

    return Material(
      color: resolved.background,
      borderRadius: AppRadius.pill,
      child: InkWell(
        borderRadius: AppRadius.pill,
        onTap: onTap,
        child: Padding(
          padding: padding,
          child: chipBody,
        ),
      ),
    );
  }

  _ChipColors _resolveColors() {
    switch (tone) {
      case StatusTone.primary:
        return _ChipColors(
          background: AppColors.primary.withValues(alpha: 0.12),
          foreground: AppColors.primary,
        );
      case StatusTone.success:
        return _ChipColors(
          background: AppColors.success.withValues(alpha: 0.12),
          foreground: AppColors.success,
        );
      case StatusTone.warning:
        return _ChipColors(
          background: AppColors.warning.withValues(alpha: 0.16),
          foreground: AppColors.warning.darken(),
        );
      case StatusTone.danger:
        return _ChipColors(
          background: AppColors.danger.withValues(alpha: 0.16),
          foreground: AppColors.danger,
        );
      case StatusTone.info:
        return _ChipColors(
          background: AppColors.info.withValues(alpha: 0.16),
          foreground: AppColors.info,
        );
      case StatusTone.neutral:
        return _ChipColors(
          background: AppColors.surfaceMuted,
          foreground: AppColors.heading,
        );
    }
  }
}

class _ChipColors {
  const _ChipColors({required this.background, required this.foreground});

  final Color background;
  final Color foreground;
}

extension _ColorShade on Color {
  Color darken([double amount = .12]) {
    assert(amount >= 0 && amount <= 1);
    final HSLColor hsl = HSLColor.fromColor(this);
    final double lightness = (hsl.lightness - amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }
}

