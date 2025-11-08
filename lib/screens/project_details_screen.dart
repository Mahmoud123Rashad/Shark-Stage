import 'package:finial_project/features/projects/data/projects_repository.dart';
import 'package:finial_project/features/projects/domain/project.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/theme/app_spacing.dart';
import '../theme/app_colors.dart';
import '../widgets/gradient_header.dart';
import '../widgets/status_chip.dart';
import '../widgets/ui_card.dart';

class ProjectDetailsScreen extends ConsumerStatefulWidget {
  const ProjectDetailsScreen({super.key, required this.projectId});

  final String projectId;

  @override
  ConsumerState<ProjectDetailsScreen> createState() =>
      _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState
    extends ConsumerState<ProjectDetailsScreen> {
  final GlobalKey<FormState> _interestFormKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _ticketController;
  late final TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _ticketController = TextEditingController();
    _noteController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _ticketController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<Project> projectAsync = ref.watch(
      projectDetailsProvider(widget.projectId),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Project details'),
        backgroundColor: AppColors.accent,
      ),
      body: projectAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Text(
              error.toString(),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (Project project) => SingleChildScrollView(
          padding: const EdgeInsets.only(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            bottom: AppSpacing.xxl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GradientHeader(
                title: project.title,
                subtitle: project.shortDesc.isNotEmpty
                    ? project.shortDesc
                    : project.description,
                actions: [
                  StatusChip(
                    label:
                        '${(project.availablePercentage ?? 0).toStringAsFixed(0)}% equity open',
                    tone: StatusTone.info,
                    icon: Icons.pie_chart_outline,
                  ),
                  StatusChip(
                    label:
                        'ROI ${project.expectedROI?.toStringAsFixed(1) ?? '0'}%',
                    tone: StatusTone.success,
                    icon: Icons.trending_up,
                  ),
                  StatusChip(
                    label: project.category.en,
                    tone: StatusTone.primary,
                    icon: Icons.category_outlined,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              if ((project.image ?? '').isNotEmpty)
                ClipRRect(
                  borderRadius: AppRadius.lg,
                  child: Image.network(
                    project.image!,
                    height: 240,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              const SizedBox(height: AppSpacing.lg),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  StatusChip(
                    label:
                        'Target \$${_formatCurrency(project.totalPrice ?? 0, decimals: 0)}',
                    tone: StatusTone.primary,
                    icon: Icons.payments_outlined,
                  ),
                  StatusChip(
                    label:
                        'Updated ${_formatDate(project.updatedAt ?? project.createdAt)}',
                    tone: StatusTone.neutral,
                    icon: Icons.schedule_outlined,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              UiCard(
                title: 'Deal overview',
                subtitle:
                    'Understand context, traction, and the strategic fit for your thesis.',
                child: Text(
                  project.description,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              UiCard(
                title: 'Investment snapshot',
                child: Column(
                  children: [
                    _SnapshotRow(
                      icon: Icons.payments_outlined,
                      label: 'Funding target',
                      value:
                          '\$${_formatCurrency(project.totalPrice ?? 0, decimals: 0)}',
                    ),
                    _SnapshotRow(
                      icon: Icons.pie_chart_outline,
                      label: 'Equity available',
                      value:
                          '${project.availablePercentage?.toStringAsFixed(0) ?? '0'}%',
                    ),
                    _SnapshotRow(
                      icon: Icons.calendar_today_outlined,
                      label: 'Last updated',
                      value:
                          _formatDate(project.updatedAt ?? project.createdAt),
                    ),
                  ],
                ),
              ),
              if (project.keyBenefits.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                UiCard(
                  title: 'Key highlights',
                  child: _BulletSection(points: project.keyBenefits),
                ),
              ],
              if (project.potentialRisks.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                UiCard(
                  title: 'Risk considerations',
                  child: _BulletSection(points: project.potentialRisks),
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              UiCard(
                title: 'Request an intro',
                subtitle:
                    'Share a few details and the SharkStage team will connect you to the founders.',
                child: Form(
                  key: _interestFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration:
                            const InputDecoration(labelText: 'Full name'),
                        validator: (String? value) => (value == null ||
                                value.trim().isEmpty)
                            ? 'Please add your name'
                            : null,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration:
                            const InputDecoration(labelText: 'Work email'),
                        validator: (String? value) => (value == null ||
                                !value.contains('@'))
                            ? 'Enter a valid email'
                            : null,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextFormField(
                        controller: _ticketController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Indicative ticket (USD)',
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextFormField(
                        controller: _noteController,
                        minLines: 3,
                        maxLines: 5,
                        decoration: const InputDecoration(
                          labelText: 'Context or thesis (optional)',
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      FilledButton(
                        onPressed: () => _submitInterest(context, project),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: AppColors.heading,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xl,
                            vertical: AppSpacing.sm,
                          ),
                        ),
                        child: const Text('Request intro'),
                      ),
                    ],
                  ),
                ),
              ),
              if ((project.image ?? '').isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                OutlinedButton.icon(
                  onPressed: () => _launchUrl(project.image!),
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Open media asset'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _submitInterest(BuildContext context, Project project) {
    if (!_interestFormKey.currentState!.validate()) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Thanks ${_nameController.text.trim().split(' ').first}, our team will connect you shortly.',
        ),
        backgroundColor: AppColors.success,
      ),
    );

    _interestFormKey.currentState!.reset();
    _nameController.clear();
    _emailController.clear();
    _ticketController.clear();
    _noteController.clear();
  }

  Future<void> _launchUrl(String url) async {
    final Uri? uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  String _formatCurrency(double value, {int decimals = 1}) {
    final NumberFormat formatter = NumberFormat.compactCurrency(
      symbol: '\$',
      decimalDigits: decimals,
    );
    return formatter.format(value);
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'recently';
    return DateFormat.yMMMd().format(date);
  }
}

class _BulletSection extends StatelessWidget {
  const _BulletSection({required this.points});

  final List<String> points;

  @override
  Widget build(BuildContext context) {
    final TextStyle? bodyStyle = Theme.of(context).textTheme.bodyMedium;
    final Color bulletColor =
        bodyStyle?.color?.withValues(alpha: 0.7) ?? Colors.black54;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...points.map(
          (String point) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '• ',
                  style: bodyStyle?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: bulletColor,
                      ) ??
                      TextStyle(color: bulletColor),
                ),
                Expanded(
                  child: Text(
                    point,
                    style: bodyStyle?.copyWith(height: 1.5),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SnapshotRow extends StatelessWidget {
  const _SnapshotRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.primary.withValues(alpha: 0.12),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelMedium
                      ?.copyWith(color: AppColors.muted),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.heading,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
