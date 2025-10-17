import 'package:finial_project/screens/add-project.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'entrepreneur_dashboard.dart';
import 'projects_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';

class EntrepreneurBottomNavBar extends StatefulWidget {
  const EntrepreneurBottomNavBar({super.key});

  @override
  State<EntrepreneurBottomNavBar> createState() => _EntrepreneurBottomNavBarState();
}

class _EntrepreneurBottomNavBarState extends State<EntrepreneurBottomNavBar> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    ProjectsScreen(),
    EntrepreneurDashboard(),
    Add_project(),
    ProfileScreen(),
    SettingsScreen(),
  ];

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
          BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), label: "Add"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
        ],
      ),
    );
  }
}
