import 'package:flutter/material.dart';
import 'package:finial_project/widgets/protected_screen.dart';
import 'package:finial_project/controllers/dashboard_controller.dart';
import 'package:finial_project/screens/dashboard/dashboard_widgets.dart';
import 'package:finial_project/screens/investments/investments_screen.dart';
import 'package:finial_project/widgets/skeletons/skeleton_list.dart';
import '../../services/notification_service.dart';
import '../../widgets/dashboard/dashboard_hero.dart';

class InvestorDashboard extends StatefulWidget {
  final String? userId;
  final String? email;

  const InvestorDashboard({super.key, this.userId, this.email});

  @override
  State<InvestorDashboard> createState() => _InvestorDashboardState();
}

class _InvestorDashboardState extends State<InvestorDashboard> {
  late final DashboardController _controller;
  List<dynamic> _notifications = [];
  bool _isLoadingNotifications = true;

  @override
  void initState() {
    super.initState();
    _controller = DashboardController(userIdOverride: widget.userId)
      ..addListener(_onControllerUpdate);
    _controller.load();
    _fetchNotifications();
  }

  void _onControllerUpdate() {
    if (mounted) setState(() {});
  }

  Future<void> _fetchNotifications() async {
    setState(() => _isLoadingNotifications = true);
    try {
      final data = await NotificationService.getNotifications();
      if (mounted) {
        setState(() => _notifications = data);
      }
    } catch (e) {
      debugPrint("Error fetching notifications: $e");
    } finally {
      if (mounted) setState(() => _isLoadingNotifications = false);
    }
  }

  Future<void> _markAsRead(String id) async {
    final success = await NotificationService.markAsRead(id);
    if (success) {
      setState(() {
        final index = _notifications.indexWhere((n) => n['_id'] == id);
        if (index != -1) _notifications[index]['isRead'] = true;
      });
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

    return ProtectedScreen(builder: (context) => Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Dashboard'),
        elevation: 0,
        actions: [
          if (widget.email != null)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  widget.email!,
                  style: TextStyle(
                    color: theme.colorScheme.onPrimary,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: _buildBody(data),
    ));
  }

  Widget _buildBody(DashboardData? data) {
    if (_controller.isLoading) {
      return const SkeletonList(count: 6);
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

    final colorScheme = Theme.of(context).colorScheme;

    return RefreshIndicator(
      onRefresh: () async {
        await _controller.load();
        await _fetchNotifications();
      },
      child: CustomScrollView(
        slivers: [
          // Hero Section
          SliverToBoxAdapter(
            child: DashboardHero(
              stats: {
                'investedCapital': data.stats.investedCapital,
                'averageRoi': data.stats.averageRoi,
              },
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                DashboardStatGrid(
                  items: [
                    DashboardStatDefinition(
                      label: 'Portfolio projects',
                      value: data.stats.totalProjects.toString(),
                      icon: Icons.business_outlined,
                      color: colorScheme.primary,
                      progress: 1,
                    ),
                    DashboardStatDefinition(
                      label: 'Invested capital',
                      value: _formatCurrency(data.stats.investedCapital),
                      icon: Icons.trending_up,
                      color: colorScheme.secondary,
                      progress: (data.stats.averageProgress / 100).clamp(0, 1),
                    ),
                    DashboardStatDefinition(
                      label: 'Avg. ROI',
                      value: '${data.stats.averageRoi.toStringAsFixed(1)}%',
                      icon: Icons.percent,
                      color: Colors.amber,
                      progress: (data.stats.averageRoi.clamp(0, 100)) / 100,
                    ),
                  ],
                ),
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
                ),
                const SizedBox(height: 12),
                Card(
                  margin: EdgeInsets.zero,
                  child: ListTile(
                    leading: const Icon(Icons.history),
                    title: const Text('Investment History'),
                    subtitle: const Text('View all your investments'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const InvestmentsScreen(),
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
                if (_isLoadingNotifications)
                  const Center(child: CircularProgressIndicator())
                else if (_notifications.isEmpty)
                  const DashboardEmptyCard(
                    icon: Icons.notifications_none,
                    title: 'No notifications yet',
                    subtitle: 'Updates about your investments will show here.',
                  )
                else
                  ..._notifications.map((n) {
                    final isRead = n['isRead'] ?? false;
                    final isDark = Theme.of(context).brightness == Brightness.dark;
                    return InkWell(
                      onTap: () => _markAsRead(n['_id']),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: isRead
                                ? [
                                    isDark
                                        ? Colors.grey.withOpacity(0.2)
                                        : Colors.grey.withOpacity(0.1),
                                    isDark
                                        ? Colors.grey.withOpacity(0.1)
                                        : Colors.grey.withOpacity(0.05),
                                  ]
                                : [
                                    colorScheme.primary.withOpacity(0.15),
                                    colorScheme.primary.withOpacity(0.05),
                                  ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isRead
                                ? Colors.transparent
                                : colorScheme.primary.withOpacity(0.3),
                            width: 1.5,
                          ),
                          boxShadow: isRead
                              ? []
                              : [
                                  BoxShadow(
                                    color: colorScheme.primary.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isRead
                                    ? Colors.grey.withOpacity(0.2)
                                    : colorScheme.primary.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.notifications,
                                color: isRead
                                    ? Colors.grey
                                    : colorScheme.primary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    n['title'] ?? 'Notification',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    n['message'] ?? "",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: colorScheme.onSurface.withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (!isRead)
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: Colors.redAccent,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.redAccent.withOpacity(0.5),
                                      blurRadius: 4,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  }),
              ]),
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
