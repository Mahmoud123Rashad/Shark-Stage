import 'package:finial_project/widgets/project_details_body.dart';
import 'package:flutter/material.dart';
import 'package:finial_project/services/auth_storage.dart';
import 'package:finial_project/theme/app_colors.dart';
import 'package:finial_project/screens/entrepreneur_bottom_nav_bar.dart';
import 'package:finial_project/screens/investor_bottom_nav_bar.dart';

import 'project_details_services.dart';

class ProjectDetailsScreen extends StatefulWidget {
  final String projectId;
  const ProjectDetailsScreen({super.key, required this.projectId});

  @override
  State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  Map<String, dynamic>? _project;
  bool _isLoading = true;
  String? _userRole;
  String? _userEmail;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _loadProject();
  }

  Future<void> _loadUserInfo() async {
    final summary = await AuthStorage.getUserSummary();
    setState(() {
      _userRole = summary['role'];
      _userEmail = summary['email'] ?? '';
      _userId = summary['id'];
    });
  }

  Future<void> _loadProject() async {
    final data = await ProjectDetailsService.fetchProjectDetails(widget.projectId);
    setState(() {
      _project = data;
      _isLoading = false;
    });
  }

  void _navigateToBottomNavBar(int index) {
    final role = _userRole?.toLowerCase();
    
    // First, try to pop back to the previous screen
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
    
    // Then navigate to BottomNavBar with the selected index
    if (role == 'entrepreneur' || role == 'owner') {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => EntrepreneurBottomNavBar(
            email: _userEmail ?? '',
            userId: _userId,
            role: _userRole,
            initialIndex: index,
          ),
        ),
        (route) => false,
      );
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => InvestorBottomNavBar(
            email: _userEmail ?? '',
            userId: _userId,
            role: _userRole,
            initialIndex: index,
          ),
        ),
        (route) => false,
      );
    }
  }

  Widget _buildBottomNavBar() {
    final colorScheme = Theme.of(context).colorScheme;
    final role = _userRole?.toLowerCase();

    if (role == 'entrepreneur' || role == 'owner') {
      return BottomNavigationBar(
        currentIndex: 0, // Project details is not in the nav, so we keep home selected
        onTap: _navigateToBottomNavBar,
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
      );
    } else {
      return BottomNavigationBar(
        currentIndex: 0,
        onTap: _navigateToBottomNavBar,
        backgroundColor: colorScheme.surface,
        selectedItemColor: AppColors.button,
        unselectedItemColor: colorScheme.onSurface.withOpacity(0.6),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.trending_up), label: "Dashboard"),
          BottomNavigationBarItem(icon: Icon(Icons.article), label: "Blog"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Project Details"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Container(
        decoration: BoxDecoration(
          color: !isDark ? Colors.grey[50] : null,
          gradient: isDark
              ? const LinearGradient(
                  colors: [
                    Color(0xFF121212),
                    Color(0xFF1E1E1E),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                )
              : null,
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _project == null
                ? const Center(child: Text("Project not found"))
                : ProjectDetailsBody(project: _project!),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }
}
