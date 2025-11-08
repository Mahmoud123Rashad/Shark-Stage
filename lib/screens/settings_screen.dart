import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_spacing.dart';
import '../theme/app_colors.dart';
import '../theme/theme_provider.dart';
import '../widgets/ui_card.dart';
import 'login_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeProvider themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(color: Colors.white)),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppColors.mainGradient),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xl,
        ),
        child: Column(
          children: [
            UiCard(
              title: 'Appearance',
              subtitle: 'Customize how SharkStage looks on your device.',
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: themeProvider.isDarkMode,
                title: const Text('Dark mode'),
                subtitle: Text(
                  themeProvider.isDarkMode ? 'Enabled' : 'Disabled',
                ),
                onChanged: (_) => themeProvider.toggleTheme(),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            UiCard(
              title: 'Notifications',
              subtitle: 'Choose when to receive updates about offers and deals.',
              child: Column(
                children: const [
                  _ToggleRow(
                    label: 'Deals and offers',
                    subtitle: 'Alerts on offers received and pending actions.',
                  ),
                  _ToggleRow(
                    label: 'Weekly report',
                    subtitle: 'Digest showing portfolio growth and activity.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            UiCard(
              title: 'Security',
              subtitle: 'Manage account access and safety.',
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.lock_outline),
                    title: const Text('Change password'),
                    subtitle: const Text('We’ll send a secure link to your email'),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Password reset instructions have been sent to your email.',
                          ),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.verified_user_outlined),
                    title: const Text('Two-factor authentication'),
                    subtitle: const Text('Add an extra layer of security.'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            UiCard(
              title: 'About SharkStage',
              subtitle:
                  'Learn more about the vision, privacy policy, and terms of service.',
              child: Column(
                children: const [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.info_outline),
                    title: Text('About'),
                    subtitle: Text('Discover how SharkStage empowers founders.'),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.privacy_tip_outlined),
                    title: Text('Privacy policy'),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.gavel_outlined),
                    title: Text('Terms of service'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            UiCard(
              title: 'Account',
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.logout, color: AppColors.danger),
                title: const Text('Logout'),
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute<Widget>(
                      builder: (_) => const LoginScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToggleRow extends StatefulWidget {
  const _ToggleRow({
    required this.label,
    this.subtitle,
  });

  final String label;
  final String? subtitle;

  @override
  State<_ToggleRow> createState() => _ToggleRowState();
}

class _ToggleRowState extends State<_ToggleRow> {
  bool enabled = true;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      value: enabled,
      title: Text(widget.label),
      subtitle: widget.subtitle != null ? Text(widget.subtitle!) : null,
      onChanged: (bool value) {
        setState(() => enabled = value);
      },
    );
  }
}
