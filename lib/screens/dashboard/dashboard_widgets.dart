import 'package:finial_project/controllers/dashboard_controller.dart';
import 'package:finial_project/controllers/project_controlller.dart';
import 'package:finial_project/screens/edit_project/edit_project_screen.dart';
import 'package:finial_project/screens/offers/project_offers_screen.dart';
import 'package:finial_project/screens/project_details/project_details_screen.dart';
import 'package:finial_project/widgets/notification_title.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class DashboardStatDefinition {
  const DashboardStatDefinition({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.progress,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final double progress;
}

class DashboardStatGrid extends StatelessWidget {
  const DashboardStatGrid({
    super.key,
    required this.items,
  });

  final List<DashboardStatDefinition> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return DashboardEmptyCard(
        icon: Icons.equalizer,
        title: 'No insights yet',
        subtitle: 'Add projects to your portfolio to unlock stats.',
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;
        if (isWide) {
          return Row(
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: i == items.length - 1 ? 0 : 12),
                    child: _DashboardStatCard(item: items[i]),
                  ),
                ),
            ],
          );
        }
        return Column(
          children: [
            for (var i = 0; i < items.length; i++)
              Padding(
                padding: EdgeInsets.only(bottom: i == items.length - 1 ? 0 : 12),
                child: _DashboardStatCard(item: items[i]),
              ),
          ],
        );
      },
    );
  }
}

class _DashboardStatCard extends StatelessWidget {
  const _DashboardStatCard({required this.item});

  final DashboardStatDefinition item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  item.color.withOpacity(0.15),
                  item.color.withOpacity(0.08),
                ]
              : [
                  Colors.white,
                  item.color.withOpacity(0.05),
                ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: item.color.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: item.color.withOpacity(isDark ? 0.3 : 0.15),
            blurRadius: 16,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      item.color.withOpacity(0.3),
                      item.color.withOpacity(0.2),
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: item.color.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  item.icon,
                  color: item.color,
                  size: 28,
                ),
              ),
              Text(
                item.value,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                  fontSize: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            item.label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: item.progress.isFinite ? item.progress.clamp(0, 1) : 0,
              minHeight: 8,
              backgroundColor: item.color.withOpacity(0.15),
              valueColor: AlwaysStoppedAnimation<Color>(item.color),
            ),
          ),
        ],
      ),
    );
  }
}

class DashboardTrendCard extends StatelessWidget {
  const DashboardTrendCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.points,
  });

  final String title;
  final String subtitle;
  final List<TrendPoint> points;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (points.isEmpty) {
      return DashboardEmptyCard(
        icon: Icons.stacked_line_chart,
        title: 'No performance data yet',
        subtitle: 'Add activity to see your monthly performance.',
      );
    }

    final maxY = points.fold<double>(0, (max, p) => p.amount > max ? p.amount : max);
    final spots = points
        .asMap()
        .entries
        .map((entry) => FlSpot(entry.key.toDouble(), entry.value.amount))
        .toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
            child: LineChart(
              LineChartData(
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 42,
                      getTitlesWidget: (value, meta) => Text(
                        _formatCompactCurrency(value),
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= points.length) {
                          return const SizedBox();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            points[index].label,
                            style: theme.textTheme.bodySmall,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  horizontalInterval: maxY > 0 ? maxY / 4 : 1,
                  drawVerticalLine: false,
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: theme.colorScheme.primary,
                    barWidth: 4,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) =>
                          FlDotCirclePainter(
                        radius: 5,
                        color: theme.colorScheme.primary,
                        strokeWidth: 3,
                        strokeColor: Colors.white,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          theme.colorScheme.primary.withOpacity(0.3),
                          theme.colorScheme.primary.withOpacity(0.05),
                        ],
                      ),
                    ),
                  ),
                ],
                minY: 0,
                maxY: (maxY * 1.1).clamp(1, double.infinity),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DashboardAllocationCard extends StatelessWidget {
  const DashboardAllocationCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.slices,
  });

  final String title;
  final String subtitle;
  final List<AllocationSlice> slices;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (slices.isEmpty) {
      return DashboardEmptyCard(
        icon: Icons.pie_chart_outline,
        title: 'No allocation data yet',
        subtitle: 'Add more projects to visualise your diversification.',
      );
    }

    final total = slices.fold<int>(0, (sum, slice) => sum + slice.count);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 240,
            child: PieChart(
              PieChartData(
                sections: slices
                    .asMap()
                    .entries
                    .map(
                      (entry) => PieChartSectionData(
                        title:
                            '${((entry.value.count / total) * 100).toStringAsFixed(0)}%',
                        value: entry.value.count.toDouble(),
                        color: _sliceColor(entry.key),
                        radius: 80,
                        titleStyle: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        badgeWidget: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.circle,
                            size: 8,
                            color: _sliceColor(entry.key),
                          ),
                        ),
                      ),
                    )
                    .toList(),
                sectionsSpace: 3,
                centerSpaceRadius: 40,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: slices
                .asMap()
                .entries
                .map(
                  (entry) => _LegendChip(
                    label: entry.value.category,
                    color: _sliceColor(entry.key),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Color _sliceColor(int index) {
    const palette = [
      Color(0xFF3A5A92),
      Color(0xFF6FA8DC),
      Color(0xFFF2C94C),
      Color(0xFFFFA94D),
      Color(0xFF7E57C2),
      Color(0xFF26A69A),
    ];
    return palette[index % palette.length];
  }
}

class _LegendChip extends StatelessWidget {
  const _LegendChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class DashboardProjectList extends StatelessWidget {
  const DashboardProjectList({
    super.key,
    required this.projects,
    required this.emptyMessage,
    this.showInvested = true,
    this.onRefresh,
  });

  final List<DashboardProject> projects;
  final String emptyMessage;
  final bool showInvested;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    if (projects.isEmpty) {
      return DashboardEmptyCard(
        icon: Icons.work_outline,
        title: 'No projects yet',
        subtitle: emptyMessage,
      );
    }

    return Column(
      children: projects
          .map((project) => DashboardProjectTile(
                project: project,
                showInvested: showInvested,
                onRefresh: onRefresh,
              ))
          .toList(),
    );
  }
}

class DashboardProjectTile extends StatelessWidget {
  const DashboardProjectTile({
    super.key,
    required this.project,
    required this.showInvested,
    this.onRefresh,
  });

  final DashboardProject project;
  final bool showInvested;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitle = showInvested && project.investedPercentage != null
        ? 'Invested ${(project.investedPercentage ?? 0).toStringAsFixed(0)}%'
        : 'Target \$${project.totalPrice.toStringAsFixed(0)}';

    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  theme.colorScheme.surface.withOpacity(0.6),
                  theme.colorScheme.surface.withOpacity(0.4),
                ]
              : [
                  Colors.white,
                  theme.colorScheme.primary.withOpacity(0.03),
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.1),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(isDark ? 0.2 : 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                      ),
                    ),
                    if (showInvested && project.investedPercentage != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Amount: \$${project.investedAmount.toStringAsFixed(2)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.secondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      project.status.toLowerCase() == 'active'
                          ? Colors.green
                          : Colors.grey,
                      project.status.toLowerCase() == 'active'
                          ? Colors.green.shade700
                          : Colors.grey.shade700,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: (project.status.toLowerCase() == 'active'
                              ? Colors.green
                              : Colors.grey)
                          .withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  project.status.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: (project.progress / 100).clamp(0, 1),
                    minHeight: 10,
                    backgroundColor:
                        theme.colorScheme.secondary.withOpacity(0.15),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      theme.colorScheme.secondary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${project.progress.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.secondary,
                ),
              ),
            ],
          ),
          if (!showInvested) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _navigateToOffers(context),
                  icon: const Icon(Icons.local_offer, size: 18),
                  label: const Text('Offers'),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _navigateToEdit(context),
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Edit'),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _confirmDelete(context),
                  icon: const Icon(Icons.delete, size: 18),
                  label: const Text('Delete'),
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                  ),
                ),
              ],
            ),
          ] else ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _navigateToProjectDetails(context),
                  icon: const Icon(Icons.visibility, size: 18),
                  label: const Text('View Details'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
      ),
    );
  }

  void _navigateToProjectDetails(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProjectDetailsScreen(projectId: project.id),
      ),
    );
  }

  void _navigateToOffers(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProjectOffersScreen(projectId: project.id),
      ),
    );
  }

  void _navigateToEdit(BuildContext context) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditProjectScreen(projectId: project.id),
      ),
    );
    if (result == true && onRefresh != null) {
      onRefresh!();
    }
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Project'),
        content: Text('Are you sure you want to delete "${project.title}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _deleteProject(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteProject(BuildContext context) async {
    final controller = ProjectController(projectId: project.id);
    final success = await controller.deleteProject(context);
    if (success && onRefresh != null) {
      onRefresh!();
    }
  }
}

class DashboardSectionTitle extends StatelessWidget {
  const DashboardSectionTitle({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}

class DashboardEmptyCard extends StatelessWidget {
  const DashboardEmptyCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.1),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 36, color: theme.colorScheme.primary),
          const SizedBox(height: 12),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class DashboardErrorState extends StatelessWidget {
  const DashboardErrorState({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 12),
            Text(
              'Something went wrong',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatCompactCurrency(double value) {
  if (value >= 1000000) {
    return '${(value / 1000000).toStringAsFixed(1)}M';
  }
  if (value >= 1000) {
    return '${(value / 1000).toStringAsFixed(1)}K';
  }
  return value.toStringAsFixed(0);
}

extension DashboardNotifications on List<String> {
  List<NotificationTile> toTiles() =>
      map((message) => NotificationTile(message: message)).toList();
}


