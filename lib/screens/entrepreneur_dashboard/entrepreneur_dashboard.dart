import 'package:finial_project/widgets/entrepreneur_project_card.dart';
import 'package:finial_project/widgets/entrepreneur_stat_card.dart';
import 'package:flutter/material.dart';
class EntrepreneurDashboard extends StatelessWidget {
  const EntrepreneurDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Entrepreneur Dashboard",
          style: theme.textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.appBarTheme.backgroundColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome... ",
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Here's a quick overview of your performance today",
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),

            // --- Statistics Section ---
            Row(
              children:  [
                EntrepreneurStatCard(
                  title: "Projects",
                  value: "12",
                  icon: Icons.business_center,
                  color: Colors.deepPurple,
                ),
                EntrepreneurStatCard(
                  title: "Earnings",
                  value: "₤ 8,420",
                  icon: Icons.attach_money,
                  color: Colors.green,
                ),
              ],
            ),
            Row(
              children: const [
                EntrepreneurStatCard(
                  title: "New Orders",
                  value: "5",
                  icon: Icons.shopping_cart,
                  color: Colors.orange,
                ),
                EntrepreneurStatCard(
                  title: "Clients",
                  value: "32",
                  icon: Icons.people_alt,
                  color: Colors.teal,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // --- Projects Section ---
            Text(
              "Current Projects",
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

             EntrepreneurProjectCard(
              projectName: "Project Management App",
              status: "In Progress",
              progress: 0.7,
            ),
             EntrepreneurProjectCard(
              projectName: "Smart Store Platform",
              status: "Under Development",
              progress: 0.4,
            ),
             EntrepreneurProjectCard(
              projectName: "Order Tracking System",
              status: "Completed",
              progress: 1.0,
            ),
          ],
        ),
      ),
    );
  }
}
