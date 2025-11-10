import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/project_details_body.dart';
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

  @override
  void initState() {
    super.initState();
    _loadProject();
  }

  Future<void> _loadProject() async {
    final data = await ProjectDetailsService.fetchProjectDetails(widget.projectId);
    setState(() {
      _project = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Project Details"),
        backgroundColor: AppColors.button,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _project == null
              ? const Center(child: Text("Project not found"))
              : ProjectDetailsBody(project: _project!),
    );
  }
}
