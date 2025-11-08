import 'package:flutter/material.dart';

import '../core/theme/app_spacing.dart';
import '../theme/app_colors.dart';

/// A reusable content card that mirrors the SharkStage web aesthetic.
class UiCard extends StatelessWidget {
  const UiCard({
    super.key,
    this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.backgroundColor,
    this.onTap,
    this.borderRadius = AppRadius.lg,
    this.elevation = 10,
  });

  final String? title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final Widget? child;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final BorderRadius borderRadius;
  final double elevation;

  bool get _hasHeader => title != null || subtitle != null || leading != null || trailing != null;

  @override
  Widget build(BuildContext context) {
    final Color effectiveColor = backgroundColor ?? AppColors.surface;
    final Widget cardContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (_hasHeader)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (leading != null)
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.md),
                    child: leading,
                  ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      if (title != null)
                        Text(
                          title!,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      if (subtitle != null)
                        Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.xs),
                          child: Text(
                            subtitle!,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: AppColors.muted),
                          ),
                        ),
                    ],
                  ),
                ),
                if (trailing != null)
                  Padding(
                    padding: const EdgeInsets.only(left: AppSpacing.md),
                    child: trailing,
                  ),
              ],
            ),
          ),
        if (child != null) child!,
      ],
    );

    final Widget body = Material(
      color: effectiveColor,
      borderRadius: borderRadius,
      elevation: elevation,
      shadowColor: AppColors.shadow,
      child: InkWell(
        borderRadius: borderRadius,
        onTap: onTap,
        child: Padding(
          padding: padding,
          child: cardContent,
        ),
      ),
    );

    return body;
  }
}

