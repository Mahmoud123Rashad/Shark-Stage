import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class InvestorDashboard extends StatelessWidget {
  const InvestorDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Investor Dashboard"),
        backgroundColor: AppColors.button,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Welcome Back, Investor 👋",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.heading,
                ),
              ),
              const SizedBox(height: 20),

              // الإحصائيات العامة
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatCard("Invested", "12 Projects", Icons.trending_up, Colors.greenAccent),
                  _buildStatCard("Available", "34 Projects", Icons.lightbulb_outline, Colors.orangeAccent),
                ],
              ),
              const SizedBox(height: 25),

              const Text(
                "Recommended Opportunities",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.heading,
                ),
              ),
              const SizedBox(height: 15),

              // قائمة المشاريع المقترحة
              _buildProjectCard(
                title: "EcoTech Startup",
                description: "Sustainable energy solution startup.",
                progress: 0.7,
                color: Colors.greenAccent,
              ),
              _buildProjectCard(
                title: "Foodie App",
                description: "AI-based restaurant recommendation platform.",
                progress: 0.45,
                color: Colors.orangeAccent,
              ),
              _buildProjectCard(
                title: "Smart Home Devices",
                description: "IoT-based security system for homes.",
                progress: 0.9,
                color: Colors.blueAccent,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // بطاقة إحصائيات
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 36),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.heading,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // بطاقة مشروع
  Widget _buildProjectCard({
    required String title,
    required String description,
    required double progress,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.heading,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: progress,
            color: color,
            backgroundColor: Colors.grey.withOpacity(0.2),
            minHeight: 6,
            borderRadius: BorderRadius.circular(10),
          ),
        ],
      ),
    );
  }
}
