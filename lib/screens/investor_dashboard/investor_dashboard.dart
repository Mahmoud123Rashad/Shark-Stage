import 'package:flutter/material.dart';
import '../../widgets/notification_title.dart';
import '../../widgets/investor_project_card.dart';
import '../../widgets/investor_stat_card.dart';

class InvestorDashboard extends StatelessWidget {
  const InvestorDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: colorScheme.primary,
        title: const Text("Investor Dashboard", style: TextStyle(color: Colors.white)),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: CircleAvatar(
              backgroundColor: colorScheme.secondary,
              child: Icon(Icons.person, color: colorScheme.onSecondary),
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Statistics Cards ---
            Row(
              children: const [
                Expanded(child: StatCard(label: "Projects", value: "12", icon: Icons.business)),
                Expanded(child: StatCard(label: "Total Invested", value: "\$45,000", icon: Icons.attach_money)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: const [
                Expanded(child: StatCard(label: "Monthly Profit", value: "\$5,200", icon: Icons.trending_up)),
                Expanded(child: StatCard(label: "Growth", value: "12%", icon: Icons.show_chart)),
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

            const ProjectCard(title: "Tech Startup", investment: "Investment: \$20,000", status: "Ongoing"),
            const ProjectCard(title: "Organic Foods", investment: "Investment: \$10,000", status: "Completed"),
            const ProjectCard(title: "Real Estate", investment: "Investment: \$15,000", status: "Ongoing"),

            const SizedBox(height: 24),
            Text(
              "Notifications",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 12),

            const NotificationTile(message: "New report available for Tech Startup."),
            const NotificationTile(message: "You received profit from Organic Foods."),
            const NotificationTile(message: "Upcoming meeting with Real Estate team."),
          ],
        ),
      ),
    );
  }
}
