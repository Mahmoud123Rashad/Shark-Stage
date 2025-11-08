import 'package:flutter/material.dart';
import '../controllers/project_controlller.dart';

class ProjectForm extends StatefulWidget {
  final String? ownerId;

  const ProjectForm({super.key, this.ownerId});

  @override
  State<ProjectForm> createState() => _ProjectFormState();
}

class _ProjectFormState extends State<ProjectForm> {
  late final ProjectController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ProjectController(ownerId: widget.ownerId);
  }

  void _updateFormState([String? newValue]) {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Form(
      key: _controller.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "Add New Project",
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _controller.buildImagePicker(context, _updateFormState),
          _controller.buildTextField("Project Title", _controller.titleController),
          _controller.buildTextField(
              "Short Description", _controller.shortDescController),
          _controller.buildTextField(
            "Details (Full Description)",
            _controller.detailsController,
            maxLines: 4,
          ),
          _controller.buildTextField(
            "Price",
            _controller.priceController,
            type: TextInputType.number,
          ),
          const SizedBox(height: 12),
          _controller.buildSaleTypeDropdown(context, _updateFormState),
          const SizedBox(height: 12),
          if (_controller.saleType.value == 'Partial')
            _controller.buildTextField(
              "Available Percentage (%)",
              _controller.percentageController,
              type: TextInputType.number,
            ),
          _controller.buildPdfUploader(context, _updateFormState),
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