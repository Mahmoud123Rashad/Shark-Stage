import 'package:finial_project/controllers/dashboard_controller.dart';
import 'package:finial_project/screens/dashboard/dashboard_widgets.dart';
import 'package:finial_project/screens/offers/sent_offers_screen.dart';
import 'package:flutter/material.dart';

class InvestorDashboard extends StatefulWidget {
  const InvestorDashboard({super.key, this.userId});

  final String? userId;

  @override
  State<InvestorDashboard> createState() => _InvestorDashboardState();
}

class _InvestorDashboardState extends State<InvestorDashboard> {
  late final DashboardController _controller;

  @override
  void initState() {
    super.initState();
    _controller = DashboardController(userIdOverride: widget.userId)
      ..addListener(_onControllerUpdate);
    _controller.load();
  }

  void _onControllerUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onControllerUpdate)
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
        title: const Text('Investor Dashboard'),
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
        label: 'Portfolio projects',
        value: stats.totalProjects.toString(),
        icon: Icons.business_outlined,
        color: colorScheme.primary,
        progress: 1,
      ),
      DashboardStatDefinition(
        label: 'Invested capital',
        value: _formatCurrency(stats.investedCapital),
        icon: Icons.trending_up,
        color: colorScheme.secondary,
        progress: (stats.averageProgress / 100).clamp(0, 1),
      ),
      DashboardStatDefinition(
        label: 'Avg. ROI',
        value: '${stats.averageRoi.toStringAsFixed(1)}%',
        icon: Icons.percent,
        color: Colors.amber,
        progress: (stats.averageRoi.clamp(0, 100)) / 100,
      ),
    ];

    return RefreshIndicator(
      onRefresh: _controller.load,
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  DashboardStatGrid(items: statItems),
                  const SizedBox(height: 16),
                  DashboardTrendCard(
                    title: 'Monthly performance',
                    subtitle:
                        'Track the momentum of your SharkStage portfolio over time.',
                    points: data.trend,
                  ),
                  const SizedBox(height: 16),
                  DashboardAllocationCard(
                    title: 'Capital allocation',
                    subtitle:
                        'Diversify across sectors to balance risk and compound returns.',
                    slices: data.allocation,
                  ),
                  const SizedBox(height: 24),
                  const DashboardSectionTitle(
                    title: 'Portfolio Projects',
                    subtitle:
                        'Review your current investments and follow their momentum.',
                  ),
                  const SizedBox(height: 12),
                  DashboardProjectList(
                    projects: data.projects,
                    emptyMessage:
                        'Once you invest in projects, they will appear here.',
                    showInvested: true,
                    onRefresh: _controller.load,
                  ),
                  const SizedBox(height: 24),
                  const DashboardSectionTitle(
                    title: 'Sent Offers',
                    subtitle: 'Manage your investment offers and track their status.',
                  ),
                  const SizedBox(height: 12),
                  Card(
                    margin: EdgeInsets.zero,
                    child: ListTile(
                      leading: const Icon(Icons.local_offer),
                      title: const Text('View Sent Offers'),
                      subtitle: const Text('See all your investment offers'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const SentOffersScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  const DashboardSectionTitle(
                    title: 'Notifications',
                    subtitle: 'Stay on top of the latest updates.',
                  ),
                  const SizedBox(height: 12),
                  if (data.notifications.isEmpty)
                    const DashboardEmptyCard(
                      icon: Icons.notifications_none,
                      title: 'No notifications yet',
                      subtitle: 'Updates about your investments will show here.',
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
