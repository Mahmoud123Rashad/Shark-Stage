import 'package:flutter/material.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    // Adapting colors for Dark/Light mode compatibility
    final primaryTextColor = colorScheme.onBackground;
    final secondaryTextColor = primaryTextColor.withOpacity(0.7);
    final cardColor = isDark ? const Color(0xFF161B22) : Colors.white;

    // Background gradient adapting to Dark/Light mode
    final backgroundGradient = LinearGradient(
      colors: isDark
          ? [const Color(0xFF0D1117), const Color(0xFF161B22)] // Dark colors
          : [Colors.white, Colors.grey.shade50], // Light colors
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "About App",
          style: theme.textTheme.titleLarge?.copyWith(
            color: primaryTextColor,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: primaryTextColor),
      ),
      body: Container(
        decoration: BoxDecoration(gradient: backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                // Large app icon (can be replaced with project logo)
                Icon(
                  Icons.lightbulb_outline,
                  size: 80,
                  color: colorScheme.primary,
                ),
                const SizedBox(height: 20),

                Text(
                  "Idea Investment Platform - Your 'Shark Stage'",
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: primaryTextColor,
                  ),
                ),
                const SizedBox(height: 15),
                
                // General app description
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    "The application connects innovators, visionary entrepreneurs, and startups with investors interested in growth and expansion. We provide the right arena to brilliantly pitch ideas, secure necessary funding, and turn dreams into tangible reality.",
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: secondaryTextColor,
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Main Features Section Title
                Text(
                  "Why Choose Us?",
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: primaryTextColor,
                  ),
                ),
                const SizedBox(height: 15),

                _buildFeatureTile(
                  context,
                  title: "Polished Idea Presentation",
                  subtitle: "A dedicated area for innovators to create professional pitches supported by images and data.",
                  icon: Icons.flash_on,
                  color: Colors.orange.shade700,
                  cardColor: cardColor,
                ),
                _buildFeatureTile(
                  context,
                  title: "Direct Investor Communication",
                  subtitle: "Smart browsing features allow investors to find opportunities matching their investment criteria and communicate instantly.",
                  icon: Icons.handshake,
                  color: Colors.green.shade700,
                  cardColor: cardColor,
                ),
                _buildFeatureTile(
                  context,
                  title: "Secure Negotiation Rooms",
                  subtitle: "Providing a controlled environment for private conversations and negotiations before finalizing investment deals.",
                  icon: Icons.lock_outline,
                  color: Colors.blue.shade700,
                  cardColor: cardColor,
                ),

                const SizedBox(height: 40),

                Text(
                  "© 2024 Shark Invest Platform. All rights reserved.",
                  style: TextStyle(color: secondaryTextColor, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper widget to build the feature tile
  Widget _buildFeatureTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color cardColor,
  }) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onBackground,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onBackground.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}