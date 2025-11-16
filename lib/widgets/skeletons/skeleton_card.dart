import 'package:flutter/material.dart';

class SkeletonCard extends StatelessWidget {
  final double height;
  final EdgeInsetsGeometry margin;
  const SkeletonCard({super.key, this.height = 100, this.margin = const EdgeInsets.symmetric(vertical: 8)});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: margin,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _bar(theme, width: 160),
          const SizedBox(height: 10),
          _bar(theme, width: 220),
          const SizedBox(height: 10),
          _bar(theme, width: double.infinity),
          const SizedBox(height: 8),
          _bar(theme, width: double.infinity),
        ],
      ),
    );
  }

  Widget _bar(ThemeData theme, {double width = 120, double height = 12}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.6),
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}


