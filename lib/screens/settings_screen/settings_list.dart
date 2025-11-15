import 'package:finial_project/screens/AboutAppScreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/api_service.dart';
import '../../services/auth_storage.dart';
import '../../theme/app_colors.dart';
import '../../theme/theme_provider.dart';
import '../login/login_screen.dart';
import 'settings_tile.dart';
// 1. استيراد شاشة "عن التطبيق"

class SettingsList extends StatefulWidget {
 const SettingsList({super.key});

 @override
 State<SettingsList> createState() => _SettingsListState();
}

class _SettingsListState extends State<SettingsList> {
 Future<void> _logout() async {
  final messenger = ScaffoldMessenger.of(context);
  try {
   await ApiService.post('auth/logout', auth: true);
  } catch (_) {
   // ignore network issues, we'll still clear local state
  }
  await AuthStorage.clear();

  if (!mounted) return;
  messenger.showSnackBar(
   const SnackBar(content: Text('Logged out successfully')),
  );
  Navigator.of(context).pushAndRemoveUntil(
   MaterialPageRoute(builder: (_) => const LoginScreen()),
   (route) => false,
  );
 }

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
     onChanged: (_) => themeProvider.toggleTheme(),
     activeThumbColor: AppColors.button,
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
      // 2. تنفيذ التنقل إلى شاشة AboutAppScreen
      Navigator.push(
       context,
       MaterialPageRoute(
        builder: (context) => const AboutAppScreen(),
       ),
      );
     },
    ),
    const Divider(),
    SettingsTile(
     icon: Icons.logout,
     title: "Logout",
     subtitle: "Sign out of your account",
     onTap: _logout,
    ),
   ],
  );
 }
}