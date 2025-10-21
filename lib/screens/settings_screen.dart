import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../theme/theme_provider.dart';
import 'login_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); 
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Settings",
          style: TextStyle(color: Colors.white), 
        ),
        centerTitle: true,
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
      ),
      body: Container(
        color: theme.scaffoldBackgroundColor,
        child: ListView(
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

            ListTile(
              leading: Icon(Icons.lock_outline, color: theme.iconTheme.color),
              title: Text(
                "Change Password",
                style: theme.textTheme.bodyMedium,
              ),
              subtitle: Text(
                "Update your account password",
                style: theme.textTheme.bodySmall,
              ),
            ),
            const Divider(),

            ListTile(
              leading: Icon(Icons.info_outline, color: theme.iconTheme.color),
              title: Text(
                "About App",
                style: theme.textTheme.bodyMedium,
              ),
              subtitle: Text(
                "Learn more about Shark Stage",
                style: theme.textTheme.bodySmall,
              ),
            ),
            const Divider(),

            ListTile(
              leading: Icon(Icons.logout, color: theme.iconTheme.color),
              title: Text(
                "Logout",
                style: theme.textTheme.bodyMedium,
              ),
              onTap: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
