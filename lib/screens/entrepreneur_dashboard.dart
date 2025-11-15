import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EntrepreneurDashboard extends StatefulWidget {
  final String email;

  const EntrepreneurDashboard({super.key, required this.email});

  @override
  State<EntrepreneurDashboard> createState() => _EntrepreneurDashboardState();
}

class _EntrepreneurDashboardState extends State<EntrepreneurDashboard> {
  bool _isLoading = true;
  Map<String, dynamic>? _userData;
  List<dynamic> _projects = [];

  bool _isNotifLoading = true;
  List<dynamic> _notifications = [];

  final String baseUrl = "https://sharkserver-production.up.railway.app";

  @override
  void initState() {
    super.initState();
    _fetchUserDashboard();
    _fetchNotifications();
  }

  Future<void> _fetchUserDashboard() async {
    try {
      final uri = Uri.parse("$baseUrl/auth/getUserByEmail?email=${widget.email}");
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _userData = data['user'] ?? {};
          _projects = data['projects'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint("Error fetching dashboard data: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchNotifications() async {
    setState(() => _isNotifLoading = true);
    try {
      final uri = Uri.parse("$baseUrl/notifications/user"); // endpoint خاص بالمستخدم
      final response = await http.get(uri, headers: {
        "Content-Type": "application/json",
        // لو عندك توكن:
        // "Authorization": "Bearer YOUR_TOKEN_HERE"
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _notifications = data['userNotifications'] ?? [];
        });
      }
    } catch (e) {
      debugPrint("Error fetching notifications: $e");
    } finally {
      setState(() => _isNotifLoading = false);
    }
  }

  Future<void> _markAsRead(String id) async {
    try {
      final uri = Uri.parse("$baseUrl/notifications/$id/read");
      final response = await http.put(uri, headers: {
        "Content-Type": "application/json",
      });

      if (response.statusCode == 200) {
        setState(() {
          final index = _notifications.indexWhere((n) => n['_id'] == id);
          if (index != -1) _notifications[index]['isRead'] = true;
        });
      }
    } catch (e) {
      debugPrint("Error marking notification as read: $e");
    }
  }

  Widget _notificationTile(BuildContext context, Map notif) {
    final theme = Theme.of(context);
    final isRead = notif['isRead'] ?? false;

    return InkWell(
      onTap: () => _markAsRead(notif['_id']),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isRead
              ? Colors.grey.withOpacity(0.2)
              : theme.cardColor.withOpacity(0.8),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(Icons.notifications, color: theme.colorScheme.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                notif['message'] ?? '',
                style: theme.textTheme.bodyMedium,
              ),
            ),
            if (!isRead)
              const Icon(Icons.circle, size: 10, color: Colors.redAccent),
          ],
        ),
      ),
    );
  }

  // --- بقى باقي الـ Dashboard كما هو ---
  Widget _statCard(BuildContext context, String title, String value, IconData icon, Color color) {
    final theme = Theme.of(context);

    return Expanded(
      child: Container(
        height: 100,
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title,
                    style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withOpacity(0.7))),
                const SizedBox(height: 6),
                Text(value,
                    style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _projectCard(BuildContext context, String projectName, String status, double progress) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(projectName,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(status, style: theme.textTheme.bodySmall),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
            color: theme.colorScheme.primary,
            minHeight: 6,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final name = "${_userData?['firstName'] ?? ''} ${_userData?['lastName'] ?? ''}";
    final projectsCount = _projects.length.toString();
    final earnings = _userData?['earnings']?.toString() ?? "₤ 0";
    final orders = _userData?['orders']?.toString() ?? "0";
    final clients = _userData?['clients']?.toString() ?? "0";

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {},
        ),
        title: Text("Entrepreneur Dashboard",
            style: theme.textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.appBarTheme.backgroundColor ?? Colors.black87,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Welcome, $name 👋", style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("Here's a quick overview of your performance today", style: theme.textTheme.bodyMedium),
            const SizedBox(height: 20),
            Row(
              children: [
                _statCard(context, "Projects", projectsCount, Icons.business_center, Colors.deepPurple),
                _statCard(context, "Earnings", earnings, Icons.attach_money, Colors.green),
              ],
            ),
            Row(
              children: [
                _statCard(context, "Orders", orders, Icons.shopping_cart, Colors.orange),
                _statCard(context, "Clients", clients, Icons.people_alt, Colors.teal),
              ],
            ),
            const SizedBox(height: 20),
            Text("Current Projects", style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            if (_projects.isEmpty)
              const Center(child: Text("No projects found"))
            else
              ..._projects.map((p) => _projectCard(
                  context,
                  p['name'] ?? 'Unnamed Project',
                  p['status'] ?? 'Unknown',
                  (p['progress'] ?? 0.0).toDouble(),
                )),

            const SizedBox(height: 20),
            Text("Notifications", style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _isNotifLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: _notifications.map((n) => _notificationTile(context, n)).toList(),
                  ),
          ],
        ),
      ),
    );
  }
}
