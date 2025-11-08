import 'package:flutter/material.dart';

import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';
import '../theme/app_colors.dart';

/// Marketing-inspired gradient header with optional actions and meta badges.
class GradientHeader extends StatelessWidget {
  const GradientHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.actions,
    this.gradient = AppColors.mainGradient,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppSpacing.xl,
      vertical: AppSpacing.xl,
    ),
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final List<Widget>? actions;
  final LinearGradient gradient;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final List<Widget> columnChildren = <Widget>[
      if (leading != null)
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: leading!,
        ),
      Text(
        title,
        style: AppTypography.lightTextTheme.displaySmall?.copyWith(
          color: Colors.white,
        ),
      ),
      if (subtitle?.isNotEmpty ?? false)
        Padding(
          padding: const EdgeInsets.only(top: AppSpacing.sm),
          child: Text(
            subtitle!,
            style: AppTypography.lightTextTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.82),
            ),
          ),
        ),
    ];

    final Widget actionRow = (actions != null && actions!.isNotEmpty)
        ? Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: actions!,
          )
        : const SizedBox.shrink();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: AppRadius.lg,
      ),
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ...columnChildren,
          if (actions != null && actions!.isNotEmpty) ...<Widget>[
            const SizedBox(height: AppSpacing.lg),
            actionRow,
          ],
        ],
      ),
    );
  }
}

