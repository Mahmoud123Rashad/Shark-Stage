import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/theme_provider.dart';
import '../login/login_screen.dart';
import 'settings_tile.dart';

class SettingsList extends StatelessWidget {
  const SettingsList({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        SwitchListTile(
          title: Text(
            "Dark Mode",
            style: theme.textTheme.bodyMedium,
          ),
          secondary: Icon(
            Icons.color_lens_outlined,
            color: theme.iconTheme.color,
          ),
          value: themeProvider.isDarkMode,
          onChanged: (value) {
            themeProvider.toggleTheme();
          },
          activeColor: AppColors.button,
          inactiveThumbColor: Colors.grey,
        ),
        const Divider(),

        SettingsTile(
          icon: Icons.lock_outline,
          title: "Change Password",
          subtitle: "Update your account password",
          onTap: () {
            // TODO: Add navigation to Change Password screen
          },
        ),
        const Divider(),

        SettingsTile(
          icon: Icons.info_outline,
          title: "About App",
          subtitle: "Learn more about Shark Stage",
          onTap: () {
            // TODO: Navigate to About screen
          },
        ),
        const Divider(),

        SettingsTile(
          icon: Icons.logout,
          title: "Logout",
          subtitle: "Sign out of your account",
          onTap: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            );
          },
        ),
      ],
    );
  }
}
