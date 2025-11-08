import 'package:flutter/material.dart';
import 'package:flutter/material.dart';

import 'investor_dashboard.dart';
import 'navigation/navigation_item.dart';
import 'navigation/navigation_shell.dart';
import 'offers_screen.dart';
import 'profile_screen.dart';
import 'projects_screen.dart';
import 'settings_screen.dart';

class InvestorBottomNavBar extends StatelessWidget {
  const InvestorBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return NavigationShell(
      initialIndex: 0,
      items: <NavigationItem>[
        NavigationItem(
          label: 'Dashboard',
          icon: Icons.auto_graph_outlined,
          activeIcon: Icons.auto_graph,
          builder: (_) => const InvestorDashboard(),
        ),
        NavigationItem(
          label: 'Discover',
          icon: Icons.search_outlined,
          activeIcon: Icons.search,
          builder: (_) => const ProjectsScreen(),
        ),
        NavigationItem(
          label: 'Offers',
          icon: Icons.handshake_outlined,
          activeIcon: Icons.handshake,
          builder: (_) => const OffersScreen(),
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
