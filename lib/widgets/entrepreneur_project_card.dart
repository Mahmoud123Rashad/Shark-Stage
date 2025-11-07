import 'package:flutter/material.dart';

class EntrepreneurProjectCard extends StatelessWidget {
  final String projectName;
  final String status;
  final double progress;

  const EntrepreneurProjectCard({
    super.key,
    required this.projectName,
    required this.status,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            projectName,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(status, style: theme.textTheme.bodySmall),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(6),
            minHeight: 6,
          ),
        ],
      ),
    );
  }
}
