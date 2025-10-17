import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.mainGradient,
        ),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const ListTile(
              leading: Icon(Icons.color_lens_outlined, color: Colors.white),
              title: Text("Theme"),
              subtitle: Text("Switch between Light and Dark mode"),
              textColor: Colors.white,
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
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text(
                "Logout",
                style: TextStyle(color: Colors.redAccent),
              ),
              onTap: () {
                // هنا ممكن تضيف تسجيل الخروج من Firebase
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Logout clicked")),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
