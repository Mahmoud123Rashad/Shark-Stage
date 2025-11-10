import 'package:finial_project/controllers/dashboard_controller.dart';
import 'package:finial_project/screens/dashboard/dashboard_widgets.dart';
import 'package:flutter/material.dart';

class EntrepreneurDashboard extends StatefulWidget {
  const EntrepreneurDashboard({super.key, this.userId});

  final String? userId;

  @override
  State<EntrepreneurDashboard> createState() => _EntrepreneurDashboardState();
}

class _EntrepreneurDashboardState extends State<EntrepreneurDashboard> {
  late final DashboardController _controller;

  @override
  void initState() {
    super.initState();
    _controller = DashboardController(userIdOverride: widget.userId)
      ..addListener(_onUpdate);
    _controller.load();
  }

  void _onUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onUpdate)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final data = _controller.data;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Entrepreneur Dashboard'),
      ),
      body: _buildBody(data),
    );
  }

  Widget _buildBody(DashboardData? data) {
    if (_controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_controller.error != null) {
      return DashboardErrorState(
        message: _controller.error!,
        onRetry: _controller.load,
      );
    }
    if (data == null) {
      return const Center(child: Text('No data available'));
    }

    final stats = data.stats;
    final colorScheme = Theme.of(context).colorScheme;
    final statItems = [
      DashboardStatDefinition(
        label: 'Active projects',
        value: stats.totalProjects.toString(),
        icon: Icons.work_outline,
        color: colorScheme.primary,
        progress: 1,
      ),
      DashboardStatDefinition(
        label: 'Capital sought',
        value: _formatCurrency(stats.totalCapital),
        icon: Icons.attach_money,
        color: Colors.green,
        progress: (stats.averageProgress / 100).clamp(0, 1),
      ),
      DashboardStatDefinition(
        label: 'Average progress',
        value: '${stats.averageProgress.toStringAsFixed(0)}%',
        icon: Icons.timeline_outlined,
        color: Colors.orange,
        progress: (stats.averageProgress.clamp(0, 100)) / 100,
      ),
    ];

    return RefreshIndicator(
      onRefresh: _controller.load,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  DashboardStatGrid(items: statItems),
                  const SizedBox(height: 16),
                  DashboardTrendCard(
                    title: 'Funding trajectory',
                    subtitle:
                        'Understand how your projects are raising capital over time.',
                    points: data.trend,
                  ),
                  const SizedBox(height: 16),
                  DashboardAllocationCard(
                    title: 'Category distribution',
                    subtitle: 'See where your projects sit across sectors.',
                    slices: data.allocation,
                  ),
                  const SizedBox(height: 24),
                  const DashboardSectionTitle(
                    title: 'Current Projects',
                    subtitle:
                        'Keep an eye on each project status and progress.',
                  ),
                  const SizedBox(height: 12),
                  DashboardProjectList(
                    projects: data.projects,
                    emptyMessage:
                        'Add a project from the add screen to start attracting investors.',
                    showInvested: false,
                  ),
                  const SizedBox(height: 24),
                  const DashboardSectionTitle(
                    title: 'Notifications',
                    subtitle: 'What’s happening across your portfolio.',
                  ),
                  const SizedBox(height: 12),
                  if (data.notifications.isEmpty)
                    const DashboardEmptyCard(
                      icon: Icons.notifications_none,
                      title: 'No notifications yet',
                      subtitle:
                          'You will see updates about your projects here.',
                    )
                  else
                    ...data.notifications.toTiles(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '\$${(amount / 1000000).toStringAsFixed(1)}M';
    }
    if (amount >= 1000) {
      return '\$${(amount / 1000).toStringAsFixed(1)}K';
    }
    return '\$${amount.toStringAsFixed(0)}';
  }
}