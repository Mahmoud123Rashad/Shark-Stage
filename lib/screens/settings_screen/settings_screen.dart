import 'package:flutter/material.dart';
import 'settings_list.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Settings",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
      ),
      body: Container(
        color: theme.scaffoldBackgroundColor,
        child: const SettingsList(),
      ),
    );
  }
}
