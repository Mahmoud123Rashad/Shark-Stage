import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../features/auth/application/auth_controller.dart';
import '../features/auth/application/auth_state.dart';
import '../features/offers/application/offers_controller.dart';
import '../features/offers/application/offers_state.dart';
import '../features/offers/domain/offer.dart';
import '../core/theme/app_spacing.dart';
import '../theme/app_colors.dart';
import '../widgets/gradient_header.dart';
import '../widgets/status_chip.dart';
import '../widgets/ui_card.dart';

class OffersScreen extends ConsumerStatefulWidget {
  const OffersScreen({super.key});

  @override
  ConsumerState<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends ConsumerState<OffersScreen> {
  late String _activeTab;

  @override
  void initState() {
    super.initState();
    final AuthState authState = ref.read(authControllerProvider);
    final String role = authState.maybeWhen(
      authenticated: (user) => user.accountType.toLowerCase(),
      orElse: () => 'investor',
    );
    _activeTab = role == 'investor' ? 'received' : 'sent';
  }

  @override
  Widget build(BuildContext context) {
    final OffersState state = ref.watch(offersControllerProvider);
    final AuthState authState = ref.watch(authControllerProvider);
    final String role = authState.maybeWhen(
      authenticated: (user) => user.accountType.toLowerCase(),
      orElse: () => 'investor',
    );

    final bool canViewSent = role == 'entrepreneur' || role == 'admin';
    final bool canViewReceived = role == 'investor' || role == 'admin';

    final List<Offer> currentList = _activeTab == 'received'
        ? state.received
        : state.sent;

    final int receivedCount = state.received.length;
    final int sentCount = state.sent.length;
    final int pendingCount = currentList
        .where((Offer offer) => offer.status == 'pending')
        .length;
    final int acceptedCount = currentList
        .where((Offer offer) => offer.status == 'accepted')
        .length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Offer Desk'),
        backgroundColor: AppColors.accent,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: state.loading
                ? null
                : () => ref.read(offersControllerProvider.notifier).load(),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.mainGradient),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.md,
                ),
                child: GradientHeader(
                  title: 'Manage your offers',
                  subtitle:
                      'Stay on top of negotiations and keep deal momentum strong.',
                  actions: [
                    StatusChip(
                      label: '$pendingCount pending',
                      tone: StatusTone.warning,
                      icon: Icons.hourglass_top_outlined,
                    ),
                    StatusChip(
                      label: '$acceptedCount accepted',
                      tone: StatusTone.success,
                      icon: Icons.verified_outlined,
                    ),
                    StatusChip(
                      label:
                          "${_activeTab == 'received' ? receivedCount : sentCount} in view",
                      tone: StatusTone.info,
                      icon: Icons.inbox_outlined,
                    ),
                  ],
                ),
              ),
              if (state.error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                  child: UiCard(
                    backgroundColor: AppColors.danger.withValues(alpha: 0.12),
                    title: 'We hit a refresh snag',
                    subtitle: state.error!,
                    leading: const Icon(Icons.error_outline,
                        color: AppColors.danger),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: () => ref
                            .read(offersControllerProvider.notifier)
                            .load(),
                        child: const Text('Retry loading offers'),
                      ),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
                child: UiCard(
                  title: 'Offer inbox',
                  subtitle: 'Switch between the offers you received and sent.',
                  child: Row(
                    children: [
                      if (canViewReceived)
                        _FilterChip(
                          label: 'Received ($receivedCount)',
                          isActive: _activeTab == 'received',
                          onTap: () => setState(() => _activeTab = 'received'),
                        ),
                      if (canViewSent) const SizedBox(width: AppSpacing.md),
                      if (canViewSent)
                        _FilterChip(
                          label: 'Sent ($sentCount)',
                          isActive: _activeTab == 'sent',
                          onTap: () => setState(() => _activeTab = 'sent'),
                        ),
                    ],
                  ),
                ),
              ),
              if (state.loading)
                const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                )
              else if (currentList.isEmpty)
                Expanded(
                  child: Center(
                    child: Text(
                      _activeTab == 'received'
                          ? 'No offers received yet.'
                          : 'No offers sent yet.',
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(color: Colors.white70),
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                    itemCount: currentList.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (BuildContext context, int index) {
                      final Offer offer = currentList[index];
                      return _OfferCard(
                        offer: offer,
                        role: role,
                        isReceived: _activeTab == 'received',
                        onAccept: (String id) => ref
                            .read(offersControllerProvider.notifier)
                            .accept(id),
                        onReject: (String id) => ref
                            .read(offersControllerProvider.notifier)
                            .reject(id),
                        onCancel: (String id) => ref
                            .read(offersControllerProvider.notifier)
                            .cancel(id),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color activeColor = AppColors.accent;
    final Color inactiveColor =
        AppColors.surfaceMuted.withValues(alpha: 0.7);

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: isActive ? activeColor : inactiveColor,
            borderRadius: AppRadius.pill,
            border: Border.all(
              color: isActive
                  ? activeColor.withValues(alpha: 0.6)
                  : AppColors.outline,
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: activeColor.withValues(alpha: 0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: isActive ? AppColors.heading : AppColors.heading,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
          ),
        ),
      ),
    );
  }
}

class _OfferCard extends StatelessWidget {
  const _OfferCard({
    required this.offer,
    required this.role,
    required this.isReceived,
    required this.onAccept,
    required this.onReject,
    required this.onCancel,
  });

  final Offer offer;
  final String role;
  final bool isReceived;
  final ValueChanged<String> onAccept;
  final ValueChanged<String> onReject;
  final ValueChanged<String> onCancel;

  @override
  Widget build(BuildContext context) {
    final String counterparty = isReceived
        ? '${offer.offeredBy?.firstName ?? ''} ${offer.offeredBy?.lastName ?? ''}'
              .trim()
        : '${offer.offeredTo?.firstName ?? ''} ${offer.offeredTo?.lastName ?? ''}'
              .trim();
    final String projectTitle = offer.project?.title ?? 'Untitled project';
    final String category = offer.project?.category.en ?? 'General';
    final String formattedAmount = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 0,
    ).format(offer.amount);
    final String createdAt = DateFormat.yMMMd().add_jm().format(
      offer.createdAt ?? DateTime.now(),
    );
    final String note = (offer.terms ?? offer.message ?? '').trim();
    final bool isPending = offer.status == 'pending';
    final StatusTone tone = _offerStatusTone(offer.status);
    final String statusLabel =
        offer.status[0].toUpperCase() + offer.status.substring(1);

    return UiCard(
      title: projectTitle,
      subtitle: 'Category • $category',
      trailing: StatusChip(
        label: statusLabel,
        tone: tone,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.sm),
          _OfferInfoRow(
            label: isReceived ? 'From' : 'To',
            value: counterparty.isEmpty ? 'N/A' : counterparty,
          ),
          _OfferInfoRow(label: 'Offer value', value: formattedAmount),
          _OfferInfoRow(label: 'Created', value: createdAt),
          if (note.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: Text(
                note,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.paragraph,
                    ),
              ),
            ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (isReceived && isPending) ...[
                FilledButton.icon(
                  onPressed: () => onAccept(offer.id),
                  icon: const Icon(Icons.check_circle, size: 18),
                  label: const Text('Accept'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.sm,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                FilledButton.icon(
                  onPressed: () => onReject(offer.id),
                  icon: const Icon(Icons.close, size: 18),
                  label: const Text('Decline'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.danger,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.sm,
                    ),
                  ),
                ),
              ] else if (!isReceived && isPending)
                OutlinedButton.icon(
                  onPressed: () => onCancel(offer.id),
                  icon: const Icon(Icons.cancel_outlined, size: 18),
                  label: const Text('Cancel offer'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OfferInfoRow extends StatelessWidget {
  const _OfferInfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.muted,
                    letterSpacing: 0.2,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.heading,
                  ),
            ),
          ),
        ],
      ),
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
