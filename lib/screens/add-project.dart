import 'package:finial_project/widgets/project_form.dart';
import 'package:flutter/material.dart';
class AddProjectScreen extends StatelessWidget {
  const AddProjectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Entrepreneur Dashboard"),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(
                  colors: [Color(0xFF121212), Color(0xFF1E1E1E)])
              : const LinearGradient(
                  colors: [Color(0xFFE3F2FD), Color(0xFFFFFFFF)]),
        ),
        child: const SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: ProjectForm(),
        ),
      ),
    );
  }
}
