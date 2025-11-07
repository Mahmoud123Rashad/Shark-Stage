import 'package:flutter/material.dart';
import 'project_card.dart';

class ProjectList extends StatelessWidget {
  final List<dynamic> projects;

  const ProjectList({super.key, required this.projects});

  @override
  Widget build(BuildContext context) {
    if (projects.isEmpty) {
      return const Center(
        child: Text(
          "No projects available",
          style: TextStyle(color: Colors.white70, fontSize: 18),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: projects.length,
      itemBuilder: (context, index) {
        final project = projects[index];
        return ProjectCard(project: project);
      },
    );
  }
}
