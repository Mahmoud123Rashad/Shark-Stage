import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'investor_dashboard.dart';
import 'profile/profile_screen.dart';
import 'projects_screen/projects_screen.dart';
import 'settings_screen/settings_screen.dart';

class InvestorBottomNavBar extends StatefulWidget {
  final String email; // استلام الإيميل من صفحة اللوجن

  const InvestorBottomNavBar({super.key, required this.email});

  @override
  State<InvestorBottomNavBar> createState() => _InvestorBottomNavBarState();
}

class _InvestorBottomNavBarState extends State<InvestorBottomNavBar> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    _pages = [
      ProjectsScreen(),
      InvestorDashboard(),
      ProfileScreen(email: '',),
      SettingsScreen(),
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
          BottomNavigationBarItem(icon: Icon(Icons.trending_up), label: "Dashboard"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
        ],
      ),
    );
  }
}
