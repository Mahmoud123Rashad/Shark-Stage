import 'package:finial_project/features/projects/application/projects_controller.dart';
import 'package:finial_project/features/projects/domain/project.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_spacing.dart';
import '../theme/app_colors.dart';
import '../widgets/gradient_header.dart';
import '../widgets/status_chip.dart';
import '../widgets/ui_card.dart';
import '../widgets/sparkline_chart.dart';

class EntrepreneurDashboard extends ConsumerWidget {
  const EntrepreneurDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Project>> projectsAsync =
        ref.watch(projectsControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: projectsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Text(error.toString(), textAlign: TextAlign.center),
          ),
        ),
        data: (List<Project> projects) {
          final _EntrepreneurMetrics metrics =
              _EntrepreneurMetrics.fromProjects(projects);
          final ProjectsController notifier =
              ref.read(projectsControllerProvider.notifier);

          return RefreshIndicator(
            onRefresh: notifier.refresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.xl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GradientHeader(
                    title: 'Build investor-ready momentum',
                    subtitle:
                        'Track capital raising progress, performance, and founder engagement at a glance.',
                    actions: [
                      StatusChip(
                        label: '${metrics.activeProjects} active projects',
                        tone: StatusTone.info,
                        icon: Icons.track_changes,
                      ),
                      StatusChip(
                        label:
                            '\$${_formatCompact(metrics.totalCapital)} target',
                        tone: StatusTone.primary,
                        icon: Icons.account_balance_wallet_outlined,
                      ),
                      StatusChip(
                        label:
                            '${metrics.avgRoi.toStringAsFixed(1)}% median ROI',
                        tone: StatusTone.success,
                        icon: Icons.trending_up,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Wrap(
                    spacing: AppSpacing.md,
                    runSpacing: AppSpacing.md,
                    children: [
                      _OverviewCard(
                        title: 'Total pipeline',
                        value: '\$${_formatCompact(metrics.totalCapital)}',
                        caption: 'Across live fundraises',
                        icon: Icons.data_thresholding_outlined,
                        color: AppColors.primary,
                      ),
                      _OverviewCard(
                        title: 'Open equity',
                        value:
                            '${metrics.openEquityPercentage.toStringAsFixed(0)}%',
                        caption:
                            '\$${_formatCompact(metrics.openEquityValue)} available',
                        icon: Icons.pie_chart_outline,
                        color: AppColors.secondary,
                      ),
                      _OverviewCard(
                        title: 'Founder engagement',
                        value: metrics.responseRateLabel,
                        caption:
                            '${metrics.recentMessages} investor touch-points this week',
                        icon: Icons.message_outlined,
                        color: AppColors.accent,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  UiCard(
                    title: 'Momentum tracker',
                    subtitle:
                        'Rolling average ROI across your portfolio as new capital is committed.',
                    child: SparklineChart(
                      data: metrics.roiTrend,
                      lineColor: AppColors.primary,
                      label: 'ROI trajectory',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  UiCard(
                    title: 'Active opportunities',
                    subtitle:
                        'Projects with the strongest investor interest right now.',
                    child: Column(
                      children: metrics.topProjects
                          .map(
                            (Project project) => _ProjectListTile(project),
                          )
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  UiCard(
                    title: 'Deal readiness checklist',
                    subtitle:
                        'Keep deal rooms refreshed to maintain investor confidence.',
                    child: Column(
                      children: const [
                        _ChecklistRow(
                          label: 'Update investor deck with latest traction',
                        ),
                        _ChecklistRow(
                          label: 'Share due diligence access permissions',
                        ),
                        _ChecklistRow(
                          label: 'Confirm legal closing timeline',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({
    required this.title,
    required this.value,
    required this.caption,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final String caption;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      child: UiCard(
        leading: CircleAvatar(
          radius: 26,
          backgroundColor: color.withValues(alpha: 0.16),
          child: Icon(icon, color: color, size: 24),
        ),
        title: title,
        child: Padding(
          padding: const EdgeInsets.only(top: AppSpacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.heading,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                caption,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.muted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProjectListTile extends StatelessWidget {
  const _ProjectListTile(this.project);

  final Project project;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withValues(alpha: 0.14),
          child: Text(
            project.title.isNotEmpty
                ? project.title[0].toUpperCase()
                : '?',
          ),
        ),
        title: Text(
          project.title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Text(
          '${project.category.en} • ROI ${project.expectedROI?.toStringAsFixed(1) ?? '0'}%',
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: AppColors.muted),
        ),
        trailing: StatusChip(
          label:
              '${project.availablePercentage?.toStringAsFixed(0) ?? '0'}% open',
          tone: StatusTone.info,
        ),
      ),
    );
  }
}

class _ChecklistRow extends StatelessWidget {
  const _ChecklistRow({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, color: AppColors.primary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _EntrepreneurMetrics {
  _EntrepreneurMetrics({
    required this.totalProjects,
    required this.activeProjects,
    required this.totalCapital,
    required this.openEquityValue,
    required this.avgRoi,
    required this.roiTrend,
    required this.topProjects,
    required this.recentMessages,
  });

  final int totalProjects;
  final int activeProjects;
  final double totalCapital;
  final double openEquityValue;
  final double avgRoi;
  final List<double> roiTrend;
  final List<Project> topProjects;
  final int recentMessages;

  double get openEquityPercentage {
    if (totalCapital == 0) return 0;
    return (openEquityValue / totalCapital) * 100;
  }

  String get responseRateLabel =>
      totalProjects == 0 ? 'No projects' : '${(0.72 * 100).toStringAsFixed(0)}%';

  static _EntrepreneurMetrics fromProjects(List<Project> projects) {
    final int total = projects.length;
    final int active = projects
        .where((Project project) => project.status.toLowerCase() == 'active')
        .length;
    final double capital = projects.fold<double>(
      0,
      (double acc, Project project) => acc + (project.totalPrice ?? 0),
    );
    final double openEquity = projects.fold<double>(
      0,
      (double acc, Project project) {
        final double price = project.totalPrice ?? 0;
        final double availablePct = project.availablePercentage ?? 0;
        return acc + ((price * availablePct) / 100);
      },
    );
    final double averageRoi = total == 0
        ? 0
        : projects
                .map((Project project) => project.expectedROI ?? 0)
                .reduce((double a, double b) => a + b) /
            total;

    final List<Project> ranked = List<Project>.of(projects)
      ..sort(
        (Project a, Project b) =>
            (b.expectedROI ?? 0).compareTo(a.expectedROI ?? 0),
      );

    final List<Project> topProjects = ranked.take(3).toList();

    final List<Project> chronological = List<Project>.of(projects)
      ..sort(
        (Project a, Project b) =>
            (a.createdAt ?? DateTime(0)).compareTo(b.createdAt ?? DateTime(0)),
      );

    double cumulative = 0;
    final List<double> roiTrend = <double>[];
    for (int i = 0; i < chronological.length; i++) {
      cumulative += chronological[i].expectedROI ?? 0;
      roiTrend.add(cumulative / (i + 1));
    }

    if (roiTrend.length < 4) {
      roiTrend.addAll(List<double>.filled(4 - roiTrend.length, averageRoi));
    }

    return _EntrepreneurMetrics(
      totalProjects: total,
      activeProjects: active,
      totalCapital: capital,
      openEquityValue: openEquity,
      avgRoi: averageRoi,
      roiTrend: roiTrend,
      topProjects: topProjects,
      recentMessages: 6,
    );
  }
}

String _formatCompact(double value) {
  if (value >= 1e9) {
    return '${(value / 1e9).toStringAsFixed(1)}B';
  }
  if (value >= 1e6) {
    return '${(value / 1e6).toStringAsFixed(1)}M';
  }
  if (value >= 1e3) {
    return '${(value / 1e3).toStringAsFixed(1)}K';
  }
  return value.toStringAsFixed(0);
}
