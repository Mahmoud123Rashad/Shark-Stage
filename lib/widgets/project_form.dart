import 'package:flutter/material.dart';
import '../controllers/project_controlller.dart';

class ProjectForm extends StatefulWidget {
  const ProjectForm({super.key});

  @override
  State<ProjectForm> createState() => _ProjectFormState();
}

class _ProjectFormState extends State<ProjectForm> {
  final _controller = ProjectController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Form(
      key: _controller.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text("Add New Project",
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold)),

          const SizedBox(height: 20),

          _controller.buildImagePicker(context),
          _controller.buildTextField("Project Title", _controller.titleController),
          _controller.buildTextField("Details", _controller.detailsController,
              maxLines: 4),
          _controller.buildTextField("Price", _controller.priceController,
              type: TextInputType.number),

          const SizedBox(height: 12),

          _controller.buildSaleTypeDropdown(context),

          const SizedBox(height: 12),

          _controller.buildPdfUploader(context),

          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: () => _controller.saveProject(context),
            child: const Text("Save Project"),
          ),
        ],
      ),
    );
  }
}
