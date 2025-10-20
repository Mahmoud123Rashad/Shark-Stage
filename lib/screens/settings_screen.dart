import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../theme/theme_provider.dart';
import 'login_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings",style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.mainGradient),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            ListTile(
              leading: const Icon(Icons.color_lens_outlined, color: Colors.white),
              title: const Text("Theme", style: TextStyle(color: Colors.white)),
              subtitle: Text(
                themeProvider.isDarkMode ? "Dark Mode" : "Light Mode",
                style: const TextStyle(color: Colors.white70),
              ),
              onTap: () {
                themeProvider.toggleTheme();
              },
            ),
            const Divider(color: Colors.white30),

            const ListTile(
              leading: Icon(Icons.lock_outline, color: Colors.white),
              title: Text("Change Password"),
              subtitle: Text("Update your account password"),
              textColor: Colors.white,
            ),
            const Divider(color: Colors.white30),

            const ListTile(
              leading: Icon(Icons.info_outline, color: Colors.white),
              title: Text("About App"),
              subtitle: Text("Learn more about Shark Stage"),
              textColor: Colors.white,
            ),
            const Divider(color: Colors.white30),

            ListTile(
              leading: const Icon(Icons.logout, color: Colors.white),
              title: const Text("Logout", style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
