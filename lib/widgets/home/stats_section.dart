import 'package:flutter/material.dart';

class StatsSection extends StatelessWidget {
  final int totalProjects;
  final double totalInvestment;
  final double averageROI;
  final int activeProjects;

  const StatsSection({
    super.key,
    required this.totalProjects,
    required this.totalInvestment,
    required this.averageROI,
    required this.activeProjects,
  });

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '\$${(amount / 1000000).toStringAsFixed(1)}M';
    }
    if (amount >= 1000) {
      return '\$${(amount / 1000).toStringAsFixed(1)}K';
    }
    return '\$${amount.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final stats = [
      _StatItem(
        icon: Icons.business_center,
        label: 'Total Projects',
        value: totalProjects.toString(),
        color: Colors.blue,
      ),
      _StatItem(
        icon: Icons.trending_up,
        label: 'Total Investment',
        value: _formatCurrency(totalInvestment),
        color: Colors.green,
      ),
      _StatItem(
        icon: Icons.percent,
        label: 'Avg. ROI',
        value: '${averageROI.toStringAsFixed(1)}%',
        color: Colors.orange,
      ),
      _StatItem(
        icon: Icons.rocket_launch,
        label: 'Active Projects',
        value: activeProjects.toString(),
        color: Colors.purple,
      ),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.5,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: stats.length,
        itemBuilder: (context, index) {
          final stat = stats[index];
          return _StatCard(
            stat: stat,
            isDark: isDark,
            theme: theme,
          );
        },
      ),
    );
  }
}

class _StatItem {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
}

class _StatCard extends StatelessWidget {
  final _StatItem stat;
  final bool isDark;
  final ThemeData theme;

  const _StatCard({
    required this.stat,
    required this.isDark,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surface.withOpacity(0.5)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: stat.color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                stat.icon,
                color: stat.color,
                size: 24,
              ),
            ),
            const Spacer(),
            Text(
              stat.value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              stat.label,
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

