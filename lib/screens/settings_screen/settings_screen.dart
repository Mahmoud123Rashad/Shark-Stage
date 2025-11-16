import 'package:flutter/material.dart';
import 'settings_list.dart';
import '../../widgets/settings/settings_hero_section.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          color: !isDark ? Colors.grey[50] : null,
          gradient: isDark
              ? const LinearGradient(
                  colors: [
                    Color(0xFF121212),
                    Color(0xFF1E1E1E),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                )
              : null,
        ),
        child: const CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: SettingsHeroSection(),
            ),
            SliverToBoxAdapter(
              child: SettingsList(),
            ),
          ],
        ),
      ),
    );
  }
}
