import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../widgets/notification_badge.dart';
import '../chatbot/chatbot_screen.dart';
import '../chat/conversations_list_screen.dart';
import '../notifications/notifications_screen.dart';
import 'project_list.dart';

class ProjectsScreen extends StatefulWidget {
  final String? userId;
  final String? role;

  const ProjectsScreen({
    super.key,
    this.userId,
    this.role,
  });

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  List<dynamic> _projects = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    fetchProjects();
  }

  Future<void> fetchProjects() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final response = await ApiService.get('projects');
      final status = response['status'] as int? ?? 500;
      if (status == 200 && response['allProjects'] is List<dynamic>) {
        setState(() {
          _projects = List<dynamic>.from(response['allProjects']);
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response['message']?.toString() ??
              'Failed to fetch projects (status $status)';
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("❌ Error fetching projects: $e");
      setState(() {
        _error = 'Failed to fetch projects: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Available Projects"),
        centerTitle: true,
        backgroundColor: theme.colorScheme.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.chat),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ConversationsListScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: NotificationBadge(
              child: const Icon(Icons.notifications),
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const NotificationsScreen(),
                ),
              ).then((_) {
                setState(() {});
              });
            },
          ),
        ],
      ),

      body: Container(
        decoration: BoxDecoration(
          color: !isDark ? Colors.white : null,
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
            : _error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _error!,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: fetchProjects,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  )
                : ProjectList(projects: _projects),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ChatBotScreen()),
          );
        },
        icon: const Icon(Icons.smart_toy_outlined),
        label: const Text("AI Bot"),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }
}
