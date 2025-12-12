import 'package:finial_project/screens/add-project-wizard.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'entrepreneur_dashboard/entrepreneur_dashboard.dart';
import 'profile/profile_screen.dart';
import 'projects_screen/projects_screen.dart';
import 'settings_screen/settings_screen.dart';
import 'blog/blog_screen.dart';

class EntrepreneurBottomNavBar extends StatefulWidget {
  final String email;
  final String? userId;
  final String? role;
  final int? initialIndex;

  const EntrepreneurBottomNavBar({
    super.key,
    required this.email,
    this.userId,
    this.role,
    this.initialIndex,
  });

  @override
  State<EntrepreneurBottomNavBar> createState() =>
      _EntrepreneurBottomNavBarState();
}

class _EntrepreneurBottomNavBarState extends State<EntrepreneurBottomNavBar> {
  late int _selectedIndex;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex ?? 0;
    _pages = [
      const ProjectsScreen(),
      const EntrepreneurDashboard(),
      const BlogScreen(),
      const AddProjectWizardScreen(), // Using new Wizard screen
      ProfileScreen(email: '',),
      const SettingsScreen(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: colorScheme.surface,
        selectedItemColor: AppColors.button,
        unselectedItemColor: colorScheme.onSurface.withOpacity(0.6),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Dashboard"),
          BottomNavigationBarItem(icon: Icon(Icons.article), label: "Blog"),
          BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline), label: "Add"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
        ],
      ),
    );
  }
}
