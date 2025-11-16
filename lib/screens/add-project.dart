import 'package:finial_project/widgets/project_form.dart';
import 'package:flutter/material.dart';
import '../widgets/project/add_project_hero_section.dart';

class AddProjectScreen extends StatelessWidget {
  final String? ownerId;
  final String? projectId;

  const AddProjectScreen({
    super.key,
    this.ownerId,
    this.projectId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isEditMode = projectId != null && projectId!.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? "Edit Project" : "Add Project"),
        centerTitle: true,
        elevation: 0,
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
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: AddProjectHeroSection(isEditMode: isEditMode),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              sliver: SliverToBoxAdapter(
                child: ProjectForm(
                  ownerId: ownerId,
                  projectId: projectId,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
