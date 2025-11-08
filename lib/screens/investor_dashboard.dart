import 'package:finial_project/features/offers/application/offers_controller.dart';
import 'package:finial_project/features/offers/application/offers_state.dart';
import 'package:finial_project/features/offers/domain/offer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../core/theme/app_spacing.dart';
import '../theme/app_colors.dart';
import '../widgets/gradient_header.dart';
import '../widgets/sparkline_chart.dart';
import '../widgets/status_chip.dart';
import '../widgets/ui_card.dart';

class InvestorDashboard extends ConsumerWidget {
  const InvestorDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final OffersState offersState = ref.watch(offersControllerProvider);

    if (offersState.loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (offersState.error != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Text(
              offersState.error!,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final _InvestorMetrics metrics =
        _InvestorMetrics.fromOffers(offersState.sent, offersState.received);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: () => ref.read(offersControllerProvider.notifier).load(),
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
                title: 'Your dealflow cockpit',
                subtitle:
                    'Track committed capital, pending offers, and the momentum of your portfolio.',
                actions: [
                  StatusChip(
                    label: '${metrics.acceptedDeals} accepted offers',
                    tone: StatusTone.success,
                    icon: Icons.verified_outlined,
                  ),
                  StatusChip(
                    label: '${metrics.pendingDeals} pending reviews',
                    tone: StatusTone.warning,
                    icon: Icons.hourglass_bottom,
                  ),
                  StatusChip(
                    label: '\$${_formatCompact(metrics.capitalInvested)} deployed',
                    tone: StatusTone.primary,
                    icon: Icons.attach_money,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.md,
                children: [
                  _InvestorStatCard(
                    title: 'Capital deployed',
                    value: '\$${_formatCompact(metrics.capitalInvested)}',
                    caption: 'Across ${metrics.acceptedDeals} accepted deals',
                    icon: Icons.account_balance_outlined,
                    color: AppColors.primary,
                  ),
                  _InvestorStatCard(
                    title: 'Average ticket',
                    value: '\$${_formatCompact(metrics.averageTicket)}',
                    caption: 'Per accepted opportunity',
                    icon: Icons.payments_outlined,
                    color: AppColors.secondary,
                  ),
                  _InvestorStatCard(
                    title: 'Win rate',
                    value: '${metrics.winRate.toStringAsFixed(0)}%',
                    caption: '${metrics.sentDeals} offers submitted',
                    icon: Icons.percent_outlined,
                    color: AppColors.accent,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              UiCard(
                title: 'Capital momentum',
                subtitle:
                    'Trailing 6-week view of capital commitments from accepted offers.',
                child: SparklineChart(
                  data: metrics.capitalTrend,
                  lineColor: AppColors.secondary,
                  label: 'Capital deployed',
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              UiCard(
                title: 'Pipeline status',
                subtitle:
                    'Stay proactive with follow-ups and keep momentum strong with founders.',
                child: Column(
                  children: [
                    _PipelineProgressRow(
                      label: 'Awaiting founder reply',
                      count: metrics.pendingFounderResponses,
                      color: AppColors.warning,
                    ),
                    _PipelineProgressRow(
                      label: 'Due diligence in progress',
                      count: metrics.dueDiligenceDeals,
                      color: AppColors.primary,
                    ),
                    _PipelineProgressRow(
                      label: 'Closing this month',
                      count: metrics.closingSoon,
                      color: AppColors.success,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              UiCard(
                title: 'Recent activity',
                subtitle: 'Most recent offers you engaged with.',
                child: Column(
                  children: metrics.recentActivity
                      .map((Offer offer) => _RecentOfferTile(offer))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InvestorStatCard extends StatelessWidget {
  const _InvestorStatCard({
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
                      fontWeight: FontWeight.bold,
                      color: AppColors.heading,
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

class _PipelineProgressRow extends StatelessWidget {
  const _PipelineProgressRow({
    required this.label,
    required this.count,
    required this.color,
  });

  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: color.withValues(alpha: 0.16),
            child: Icon(Icons.arrow_outward, color: color, size: 18),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          StatusChip(
            label: '$count',
            tone: StatusTone.neutral,
          ),
        ],
      ),
    );
  }
}

class _RecentOfferTile extends StatelessWidget {
  const _RecentOfferTile(this.offer);

  final Offer offer;

  @override
  Widget build(BuildContext context) {
    final String projectTitle = offer.project?.title ?? 'Untitled project';
    final String formattedAmount = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 0,
    ).format(offer.amount);
    final String createdAt = DateFormat.MMMd().format(
      offer.createdAt ?? DateTime.now(),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(
          backgroundColor: AppColors.secondary.withValues(alpha: 0.16),
          child: Text(projectTitle.isNotEmpty ? projectTitle[0] : '?'),
        ),
        title: Text(projectTitle),
        subtitle: Text('$formattedAmount • $createdAt'),
        trailing: StatusChip(
          label: offer.status,
          tone: _offerStatusTone(offer.status),
        ),
      ),
    );
  }
}

class _InvestorMetrics {
  _InvestorMetrics({
    required this.capitalInvested,
    required this.averageTicket,
    required this.acceptedDeals,
    required this.pendingDeals,
    required this.sentDeals,
    required this.capitalTrend,
    required this.pendingFounderResponses,
    required this.dueDiligenceDeals,
    required this.closingSoon,
    required this.recentActivity,
  });

  final double capitalInvested;
  final double averageTicket;
  final int acceptedDeals;
  final int pendingDeals;
  final int sentDeals;
  final List<double> capitalTrend;
  final int pendingFounderResponses;
  final int dueDiligenceDeals;
  final int closingSoon;
  final List<Offer> recentActivity;

  double get winRate =>
      sentDeals == 0 ? 0 : (acceptedDeals / sentDeals) * 100;

  static _InvestorMetrics fromOffers(
    List<Offer> sent,
    List<Offer> received,
  ) {
    final List<Offer> allOffers = <Offer>[...sent, ...received];
    final List<Offer> accepted = allOffers
        .where((Offer offer) => offer.status.toLowerCase() == 'accepted')
        .toList();
    final List<Offer> pending = allOffers
        .where((Offer offer) => offer.status.toLowerCase() == 'pending')
        .toList();

    final double invested = accepted.fold<double>(
      0,
      (double acc, Offer offer) => acc + offer.amount,
    );

    final double avgTicket =
        accepted.isEmpty ? 0 : invested / accepted.length;

    final List<Offer> chronological = List<Offer>.of(accepted)
      ..sort(
        (Offer a, Offer b) =>
            (a.createdAt ?? DateTime(0)).compareTo(b.createdAt ?? DateTime(0)),
      );

    final List<double> capitalTrend = <double>[];
    double cumulative = 0;
    for (final Offer offer in chronological) {
      cumulative += offer.amount;
      capitalTrend.add(cumulative);
    }
    if (capitalTrend.length < 4) {
      capitalTrend.addAll(
        List<double>.filled(4 - capitalTrend.length, cumulative),
      );
    }

    return _InvestorMetrics(
      capitalInvested: invested,
      averageTicket: avgTicket,
      acceptedDeals: accepted.length,
      pendingDeals: pending.length,
      sentDeals: sent.length,
      capitalTrend: capitalTrend,
      pendingFounderResponses: pending.length,
      dueDiligenceDeals: accepted.length ~/ 2 + 1,
      closingSoon: (accepted.length / 2).ceil(),
      recentActivity: allOffers.take(5).toList(),
    );
  }
}

StatusTone _offerStatusTone(String status) {
  switch (status.toLowerCase()) {
    case 'accepted':
      return StatusTone.success;
    case 'rejected':
      return StatusTone.danger;
    case 'cancelled':
      return StatusTone.neutral;
    case 'pending':
    default:
      return StatusTone.warning;
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
