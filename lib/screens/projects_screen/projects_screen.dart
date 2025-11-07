import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../chatbot/chatbot_screen.dart';
import 'project_list.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  final String baseUrl = "https://sharkserver-production.up.railway.app";
  List<dynamic> _projects = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProjects();
  }

  Future<void> fetchProjects() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/projects"));

      debugPrint("📡 GET /projects => ${response.statusCode}");
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _projects = data["allProjects"] ?? [];
          _isLoading = false;
        });
      } else {
        throw Exception("Failed to fetch projects");
      }
    } catch (e) {
      debugPrint("❌ Error fetching projects: $e");
      setState(() => _isLoading = false);
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
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(
                  colors: [Color(0xFF121212), Color(0xFF1E1E1E)],
                )
              : const LinearGradient(
                  colors: [
                    Color.fromARGB(255, 42, 147, 238),
                    Color.fromARGB(255, 74, 177, 246),
                    Color.fromARGB(255, 145, 207, 234),
                  ],
                ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
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
