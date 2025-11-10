// lib/screens/investor_dashboard.dart
import 'package:flutter/material.dart';
import '../services/notification_service.dart';

class InvestorDashboard extends StatefulWidget {
  final String email;
  const InvestorDashboard({super.key, required this.email});

  @override
  State<InvestorDashboard> createState() => _InvestorDashboardState();
}

class _InvestorDashboardState extends State<InvestorDashboard> {
  final NotificationService _notificationService = NotificationService();
  List<dynamic> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    setState(() => _isLoading = true);
    try {
      final data = await _notificationService.getNotifications();
      if (!mounted) return;
      setState(() {
        _notifications = data;
      });
    } catch (e) {
      print("Error fetching notifications: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _markAsRead(String id) async {
    final success = await _notificationService.markAsRead(id);
    if (success) {
      setState(() {
        final index = _notifications.indexWhere((n) => n['_id'] == id);
        if (index != -1) _notifications[index]['isRead'] = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: colorScheme.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Investor Dashboard",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: CircleAvatar(
              backgroundColor: colorScheme.secondary,
              child: const Icon(Icons.person, color: Colors.white),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome, ${widget.email}",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),

            // --- Statistics Cards ---
            Row(
              children: [
                Expanded(child: _statCard(context, "Projects", "12", Icons.business)),
                Expanded(
                  child: _statCard(context, "Total Invested", "\$45,000", Icons.attach_money),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _statCard(context, "Monthly Profit", "\$5,200", Icons.trending_up)),
                Expanded(child: _statCard(context, "Growth", "12%", Icons.show_chart)),
              ],
            ),

            const SizedBox(height: 24),
            Text(
              "Recent Projects",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 12),
            _projectCard(context, "Tech Startup", "Investment: \$20,000", "Ongoing"),
            _projectCard(context, "Organic Foods", "Investment: \$10,000", "Completed"),
            _projectCard(context, "Real Estate", "Investment: \$15,000", "Ongoing"),

            const SizedBox(height: 24),
            Text(
              "Notifications",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 12),

            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: _notifications.map((notification) {
                      final isRead = notification['isRead'] ?? false;
                      return InkWell(
                        onTap: () => _markAsRead(notification['_id']),
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isRead
                                ? Colors.grey.withOpacity(0.2)
                                : colorScheme.surfaceVariant.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.notifications, color: colorScheme.primary),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  notification['message'] ?? "",
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurface.withOpacity(0.8),
                                  ),
                                ),
                              ),
                              if (!isRead)
                                const Icon(Icons.circle, size: 10, color: Colors.redAccent),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
          ],
        ),
      ),
    );
  }

  // ---------- Widgets ----------
  Widget _statCard(BuildContext context, String label, String value, IconData icon) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: 90,
      margin: const EdgeInsets.all(6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: colorScheme.primary.withOpacity(0.2),
            child: Icon(icon, color: colorScheme.primary),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: colorScheme.onSurface.withOpacity(0.7))),
                const SizedBox(height: 4),
                Text(value,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _projectCard(BuildContext context, String title, String investment, String status) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color statusColor = switch (status) {
      "Completed" => Colors.green,
      "Ongoing" => Colors.orange,
      _ => Colors.grey,
    };

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surface.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: theme.shadowColor.withOpacity(0.15), blurRadius: 6)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title,
                  style: theme.textTheme.bodyLarge
                      ?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
              const SizedBox(height: 4),
              Text(investment,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: colorScheme.onSurface.withOpacity(0.7))),
            ]),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(status,
                style: TextStyle(color: statusColor, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
