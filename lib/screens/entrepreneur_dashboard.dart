import 'package:flutter/material.dart';
import '../theme/app_colors.dart'; 

class EntrepreneurDashboard extends StatelessWidget {
  const EntrepreneurDashboard({super.key});

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        height: 100,
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
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
                Text(
                  title,
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.heading,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _projectCard(String projectName, String status, double progress) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: AppColors.shadow, blurRadius: 6, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(projectName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.heading)),
          const SizedBox(height: 6),
          Text(status, style: const TextStyle(color: AppColors.paragraph)),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.soft,
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(6),
            minHeight: 6,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          "Entrepreneur Dashboard",
          style: TextStyle(color: Colors.white),
        ),
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: AppColors.mainGradient)),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text(
              "Welcome 👋",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.heading),
            ),
            const SizedBox(height: 8),
            const Text(
              "Here's a quick overview of your performance today",
              style: TextStyle(color: AppColors.paragraph),
            ),

            const SizedBox(height: 20),

            // Statistic cards
            Row(
              children: [
                _statCard("Projects", "12", Icons.business_center, AppColors.primary),
                _statCard("Earnings", "₤ 8,420", Icons.attach_money, AppColors.button),
              ],
            ),
            Row(
              children: [
                _statCard("New Orders", "5", Icons.shopping_cart, AppColors.secondary),
                _statCard("Clients", "32", Icons.people_alt, Colors.teal),
              ],
            ),

            const SizedBox(height: 20),

            // Projects section
            const Text(
              "Current Projects",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.heading),
            ),
            const SizedBox(height: 10),

            _projectCard("Project Management App", "In Progress", 0.7),
            _projectCard("Smart Store Platform", "Under Development", 0.4),
            _projectCard("Order Tracking System", "Completed", 1.0),
          ],
        ),
      ),
    );
  }
}
