import 'package:finial_project/screens/add_project.dart';
import 'package:flutter/material.dart';

import 'entrepreneur_dashboard.dart';
import 'navigation/navigation_item.dart';
import 'navigation/navigation_shell.dart';
import 'projects_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';

class EntrepreneurBottomNavBar extends StatelessWidget {
  const EntrepreneurBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return NavigationShell(
      initialIndex: 1,
      items: <NavigationItem>[
        NavigationItem(
          label: 'Projects',
          icon: Icons.folder_copy_outlined,
          activeIcon: Icons.folder_copy,
          builder: (_) => const ProjectsScreen(),
        ),
        NavigationItem(
          label: 'Dashboard',
          icon: Icons.dashboard_outlined,
          activeIcon: Icons.dashboard,
          builder: (_) => const EntrepreneurDashboard(),
        ),
        NavigationItem(
          label: 'Publish',
          icon: Icons.add_circle_outline,
          activeIcon: Icons.add_circle,
          builder: (_) => const AddProject(),
        ),
        NavigationItem(
          label: 'Profile',
          icon: Icons.person_outline,
          activeIcon: Icons.person,
          builder: (_) => const ProfileScreen(),
        ),
        NavigationItem(
          label: 'Settings',
          icon: Icons.tune,
          activeIcon: Icons.tune_rounded,
          builder: (_) => const SettingsScreen(),
        ),
      ],
    );
  }
}
