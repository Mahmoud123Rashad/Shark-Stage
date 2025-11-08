// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import '../theme/app_colors.dart';
// import 'project_details_screen.dart';

// class ProjectsScreen extends StatelessWidget {
//   const ProjectsScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Available Projects"),
//         backgroundColor: AppColors.button,
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance
//             .collection('projects')
//             .orderBy('createdAt', descending: true)
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             return const Center(child: Text("No projects available."));
//           }

//           final projects = snapshot.data!.docs;

//           return ListView.builder(
//             padding: const EdgeInsets.all(10),
//             itemCount: projects.length,
//             itemBuilder: (context, index) {
//               final project = projects[index];
//               return Card(
//                 margin: const EdgeInsets.symmetric(vertical: 8),
//                 elevation: 4,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(15),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(12),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Project Image
//                       if (project['imageUrl'] != null && project['imageUrl'] != '')
//                         ClipRRect(
//                           borderRadius: BorderRadius.circular(12),
//                           child: Image.network(
//                             project['imageUrl'],
//                             height: 180,
//                             width: double.infinity,
//                             fit: BoxFit.cover,
//                           ),
//                         ),
//                       const SizedBox(height: 10),

//                       // Project Title
//                       Text(
//                         project['title'],
//                         style: const TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 5),

//                       // Project Details (3 lines)
//                       Text(
//                         project['details'],
//                         maxLines: 3,
//                         overflow: TextOverflow.ellipsis,
//                         style: const TextStyle(fontSize: 16, color: Colors.grey),
//                       ),
//                       const SizedBox(height: 5),

//                       // Price
//                       Text(
//                         "Price: \$${project['price']}",
//                         style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                       ),
//                       const SizedBox(height: 8),

//                       // View Details Button
//                       Align(
//                         alignment: Alignment.centerRight,
//                         child: ElevatedButton(
//                           onPressed: () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (_) => ProjectDetailsScreen(
//                                   projectId: project.id,
//                                 ),
//                               ),
//                             );
//                           },
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: AppColors.button,
//                           ),
//                           child: const Text("View Full Project"),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
import 'package:finial_project/features/projects/application/projects_controller.dart';
import 'package:finial_project/features/projects/domain/project.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../core/theme/app_spacing.dart';
import '../theme/app_colors.dart';
import '../widgets/status_chip.dart';
import '../widgets/ui_card.dart';
import '../widgets/gradient_header.dart';
import 'chat_list_screen.dart';
import 'offers_screen.dart';
import 'project_details_screen.dart';

class ProjectsScreen extends ConsumerStatefulWidget {
  const ProjectsScreen({super.key});

  @override
  ConsumerState<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends ConsumerState<ProjectsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String selectedCategory = 'all';
  String selectedStatus = 'all';
  double roiRange = 0;
  String sortBy = 'newest';
  int currentPage = 1;
  static const int projectsPerPage = 9;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<Project>> projectsAsync = ref.watch(
      projectsControllerProvider,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Projects'),
        backgroundColor: AppColors.accent,
        actions: [
          IconButton(
            icon: const Icon(Icons.handshake_outlined),
            tooltip: 'View offers',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<Widget>(builder: (_) => const OffersScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            tooltip: 'Messages',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<Widget>(
                  builder: (_) => const ChatListScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.mainGradient),
        child: projectsAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
          error: (Object error, StackTrace stackTrace) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(height: 12),
                Text(
                  error.toString(),
                  style: const TextStyle(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () =>
                      ref.read(projectsControllerProvider.notifier).refresh(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
          data: (List<Project> projects) {
            final List<Project> filtered = _filterAndSortProjects(projects);
            final int totalPages = (filtered.length / projectsPerPage)
                .ceil()
                .clamp(1, 999);
            currentPage = currentPage.clamp(1, totalPages);

            final int startIndex = (currentPage - 1) * projectsPerPage;
            final int endIndex = (startIndex + projectsPerPage).clamp(
              0,
              filtered.length,
            );
            final List<Project> currentProjects = filtered.sublist(
              startIndex,
              endIndex,
            );

            return RefreshIndicator(
              onRefresh: () async =>
                  ref.read(projectsControllerProvider.notifier).refresh(),
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _buildHeroSection(projects)),
                  SliverToBoxAdapter(child: _buildInsightsRow(projects)),
                  SliverToBoxAdapter(child: _buildFilterBar(projects)),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.sm,
                      ),
                      child: Text(
                        'Showing ${currentProjects.length} of ${filtered.length} projects',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ),
                  currentProjects.isEmpty
                      ? const SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: Text(
                              'No projects found with the selected filters.',
                              style: TextStyle(color: Colors.white70),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : SliverPadding(
                          padding: const EdgeInsets.all(16),
                          sliver: SliverGrid(
                            delegate: SliverChildBuilderDelegate((
                              BuildContext context,
                              int index,
                            ) {
                              final Project project = currentProjects[index];
                              return _ProjectCard(project: project);
                            }, childCount: currentProjects.length),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 1,
                                  mainAxisSpacing: 16,
                                  crossAxisSpacing: 16,
                                  childAspectRatio: 0.82,
                                ),
                          ),
                        ),
                  if (totalPages > 1)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: _buildPagination(totalPages),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  List<Project> _filterAndSortProjects(List<Project> projects) {
    List<Project> filtered = projects.where((Project project) {
      final bool matchesSearch =
          _searchController.text.isEmpty ||
          project.title.toLowerCase().contains(
            _searchController.text.toLowerCase(),
          ) ||
          project.description.toLowerCase().contains(
            _searchController.text.toLowerCase(),
          );

      final bool matchesCategory =
          selectedCategory == 'all' ||
          project.category.en.toLowerCase() == selectedCategory.toLowerCase();

      final bool matchesStatus =
          selectedStatus == 'all' || project.status == selectedStatus;

      final bool matchesRoi =
          roiRange == 0 || (project.expectedROI ?? 0) >= roiRange;

      return matchesSearch && matchesCategory && matchesStatus && matchesRoi;
    }).toList();

    filtered.sort((Project a, Project b) {
      switch (sortBy) {
        case 'roi-high':
          return (b.expectedROI ?? 0).compareTo(a.expectedROI ?? 0);
        case 'networth-high':
          return (b.totalPrice ?? 0).compareTo(a.totalPrice ?? 0);
        case 'most-funded':
          return (b.availablePercentage ?? 0).compareTo(
            a.availablePercentage ?? 0,
          );
        case 'newest':
        default:
          return (b.createdAt ?? DateTime(0)).compareTo(
            a.createdAt ?? DateTime(0),
          );
      }
    });

    return filtered;
  }

  Widget _buildHeroSection(List<Project> projects) {
    final int activeProjects = projects
        .where((Project project) => project.status.toLowerCase() == 'active')
        .length;
    final double avgRoi = projects.isEmpty
        ? 0
        : projects
                .map((Project project) => project.expectedROI ?? 0)
                .reduce((double a, double b) => a + b) /
            projects.length;
    final double totalCapital = projects.fold<double>(
      0,
      (double acc, Project project) => acc + (project.totalPrice ?? 0),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xxl,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: GradientHeader(
        title: 'Discover investment-ready ventures',
        subtitle:
            'Filter by sector, ROI, and availability to build your SharkStage dealflow.',
        actions: <Widget>[
          StatusChip(
            label: '$activeProjects active deals',
            tone: StatusTone.info,
            icon: Icons.track_changes,
          ),
          StatusChip(
            label: '${avgRoi.toStringAsFixed(1)}% median ROI',
            tone: StatusTone.success,
            icon: Icons.trending_up,
          ),
          StatusChip(
            label: '\$${_formatCompactCurrency(totalCapital)} pipeline',
            tone: StatusTone.primary,
            icon: Icons.account_balance_wallet_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsRow(List<Project> projects) {
    if (projects.isEmpty) {
      return const SizedBox.shrink();
    }

    final double totalCapital = projects.fold<double>(
      0,
      (double acc, Project project) => acc + (project.totalPrice ?? 0),
    );
    final double averageTicket =
        projects.isEmpty ? 0 : totalCapital / projects.length;
    final double openEquity = projects.fold<double>(
      0,
      (double acc, Project project) {
        final double price = project.totalPrice ?? 0;
        final double availablePct = project.availablePercentage ?? 0;
        return acc + ((price * availablePct) / 100);
      },
    );
    final double avgRoi = projects.isEmpty
        ? 0
        : projects
                .map((Project project) => project.expectedROI ?? 0)
                .reduce((double a, double b) => a + b) /
            projects.length;

    return SizedBox(
      height: 164,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        children: <Widget>[
          _MetricTile(
            title: 'Total deal value',
            description: 'Across the live marketplace',
            value: '\$${_formatCompactCurrency(totalCapital)}',
            icon: Icons.account_balance_wallet_outlined,
            tone: StatusTone.primary,
          ),
          const SizedBox(width: AppSpacing.md),
          _MetricTile(
            title: 'Open equity',
            description: 'Still available for allocation',
            value: '\$${_formatCompactCurrency(openEquity)}',
            icon: Icons.pie_chart_outline,
            tone: StatusTone.info,
          ),
          const SizedBox(width: AppSpacing.md),
          _MetricTile(
            title: 'Average ROI',
            description: 'Projected return across listings',
            value: '${avgRoi.toStringAsFixed(1)}%',
            icon: Icons.trending_up,
            tone: StatusTone.success,
          ),
          const SizedBox(width: AppSpacing.md),
          _MetricTile(
            title: 'Avg. ticket size',
            description: 'Median capital per opportunity',
            value: '\$${_formatCompactCurrency(averageTicket)}',
            icon: Icons.payments_outlined,
            tone: StatusTone.warning,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(List<Project> projects) {
    final Set<String> categories = {
      'all',
      ...projects
          .map((Project project) => project.category.en)
          .where((String category) => category.isNotEmpty),
    };

    final Map<String, String> sortOptions = <String, String>{
      'newest': 'Newest',
      'roi-high': 'ROI high → low',
      'networth-high': 'Ticket high → low',
      'most-funded': 'Most funded',
    };

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: UiCard(
        title: 'Refine your dealflow',
        subtitle:
            'Combine filters to surface opportunities that match your thesis.',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by company, market, or keyword',
                prefixIcon: const Icon(Icons.search),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _DropdownChip(
                    label: 'Category',
                    value: selectedCategory,
                    items: categories,
                    onChanged: (String? value) {
                      setState(() {
                        selectedCategory = value ?? 'all';
                        currentPage = 1;
                      });
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _DropdownChip(
                    label: 'Status',
                    value: selectedStatus,
                    items: const {'all', 'active', 'closed'},
                    onChanged: (String? value) {
                      setState(() {
                        selectedStatus = value ?? 'all';
                        currentPage = 1;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Minimum ROI (${roiRange.toStringAsFixed(0)}%)',
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium
                            ?.copyWith(color: AppColors.muted),
                      ),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: AppColors.primary,
                          inactiveTrackColor:
                              AppColors.primary.withValues(alpha: 0.15),
                          thumbColor: AppColors.accent,
                          overlayColor: AppColors.accent.withValues(alpha: 0.2),
                        ),
                        child: Slider(
                          value: roiRange,
                          max: 100,
                          divisions: 20,
                          onChanged: (double value) {
                            setState(() {
                              roiRange = value;
                              currentPage = 1;
                            });
                          },
                          label: roiRange.toStringAsFixed(0),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sort results',
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium
                            ?.copyWith(color: AppColors.muted),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: sortOptions.entries.map((entry) {
                          final bool isSelected = sortBy == entry.key;
                          return ChoiceChip(
                            label: Text(entry.value),
                            selected: isSelected,
                            onSelected: (bool selected) {
                              setState(() {
                                sortBy = entry.key;
                                currentPage = 1;
                              });
                            },
                            labelStyle: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.heading,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                ),
                            selectedColor:
                                AppColors.accent.withValues(alpha: 0.2),
                            backgroundColor:
                                AppColors.surfaceMuted.withValues(alpha: 0.7),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPagination(int totalPages) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: currentPage > 1
              ? () => setState(() => currentPage -= 1)
              : null,
          icon: const Icon(Icons.chevron_left),
        ),
        Text(
          'Page $currentPage of $totalPages',
          style: const TextStyle(color: Colors.white),
        ),
        IconButton(
          onPressed: currentPage < totalPages
              ? () => setState(() => currentPage += 1)
              : null,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }
}

class _DropdownChip extends StatelessWidget {
  const _DropdownChip({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String value;
  final Set<String> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context)
              .textTheme
              .labelMedium
              ?.copyWith(color: AppColors.muted),
        ),
        const SizedBox(height: AppSpacing.xs),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surfaceMuted.withValues(alpha: 0.8),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
          ),
          borderRadius: AppRadius.md,
          dropdownColor: AppColors.surface,
          items: items
              .map(
                (String item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(_formatFilterLabel(item)),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({required this.project});

  final Project project;

  static const String _fallbackImage =
      'https://images.unsplash.com/photo-1506765515384-028b60a970df?auto=format&fit=crop&w=800&q=60';

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String coverImage =
        (project.image ?? '').isNotEmpty ? project.image! : _fallbackImage;
    final StatusTone tone = _statusTone(project.status);
    final String statusLabel = _formatFilterLabel(project.status);

    return UiCard(
      onTap: () => _openDetails(context),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: AppRadius.md,
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                coverImage,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: AppColors.surfaceMuted,
                  alignment: Alignment.center,
                  child: const Icon(Icons.image_not_supported_outlined),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  project.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleLarge,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              StatusChip(
                label: statusLabel,
                tone: tone,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            project.shortDesc.isNotEmpty
                ? project.shortDesc
                : project.description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.paragraph,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              StatusChip(
                label: project.category.en,
                icon: Icons.category_outlined,
              ),
              StatusChip(
                label: 'ROI ${_formatDouble(project.expectedROI)}%',
                icon: Icons.trending_up,
                tone: StatusTone.success,
              ),
              StatusChip(
                label:
                    '${(project.availablePercentage ?? 0).toStringAsFixed(0)}% open',
                icon: Icons.pie_chart_outline,
                tone: StatusTone.info,
              ),
              StatusChip(
                label:
                    '\$${_formatCompactCurrency(project.totalPrice ?? 0)} target',
                icon: Icons.payments_outlined,
                tone: StatusTone.primary,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Updated',
                    style: theme.textTheme.labelSmall
                        ?.copyWith(color: AppColors.muted),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    _formatDate(project.updatedAt ?? project.createdAt),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: () => _openDetails(context),
                icon: const Icon(Icons.visibility_outlined, size: 18),
                label: const Text('View details'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: AppColors.heading,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openDetails(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute<Widget>(
        builder: (_) => ProjectDetailsScreen(projectId: project.id),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.title,
    required this.description,
    required this.value,
    required this.icon,
    required this.tone,
  });

  final String title;
  final String description;
  final String value;
  final IconData icon;
  final StatusTone tone;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color toneColor = _toneColor(tone);

    return SizedBox(
      width: 220,
      child: UiCard(
        title: title,
        subtitle: description,
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: toneColor.withValues(alpha: 0.16),
          child: Icon(icon, color: toneColor),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: AppSpacing.sm),
          child: Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: AppColors.heading,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

Color _toneColor(StatusTone tone) {
  switch (tone) {
    case StatusTone.primary:
      return AppColors.primary;
    case StatusTone.success:
      return AppColors.success;
    case StatusTone.warning:
      return AppColors.warning;
    case StatusTone.danger:
      return AppColors.danger;
    case StatusTone.info:
      return AppColors.info;
    case StatusTone.neutral:
      return AppColors.heading;
  }
}

StatusTone _statusTone(String status) {
  final String normalized = status.toLowerCase();
  if (normalized == 'active' || normalized == 'open') {
    return StatusTone.success;
  }
  if (normalized == 'closed' || normalized == 'completed') {
    return StatusTone.warning;
  }
  if (normalized == 'rejected' || normalized == 'cancelled') {
    return StatusTone.danger;
  }
  return StatusTone.neutral;
}

String _formatDouble(double? value) => (value ?? 0).toStringAsFixed(1);

String _formatDate(DateTime? date) {
  if (date == null) return 'Recently';
  return DateFormat.yMMMd().format(date);
}

String _formatCompactCurrency(double value) {
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

String _formatFilterLabel(String value) {
  if (value.trim().isEmpty) return value;
  if (value.toLowerCase() == 'all') return 'All';
  return value
      .split(RegExp(r'[\s_-]+'))
      .map(
        (String word) =>
            word.isEmpty ? word : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
      )
      .join(' ');
}

