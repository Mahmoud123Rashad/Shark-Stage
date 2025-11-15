import 'package:flutter/material.dart';
import '../../widgets/project_form.dart';

class EditProjectScreen extends StatelessWidget {
  final String projectId;
  final String? ownerId;

  const EditProjectScreen({
    super.key,
    required this.projectId,
    this.ownerId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Project"),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(
                  colors: [Color(0xFF121212), Color(0xFF1E1E1E)],
                )
              : const LinearGradient(
                  colors: [Color(0xFFE3F2FD), Color(0xFFFFFFFF)],
                ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ProjectForm(
            ownerId: ownerId,
            projectId: projectId,
          ),
        ),
      ),
    );
  }
}

