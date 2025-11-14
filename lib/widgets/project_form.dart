import 'package:flutter/material.dart';
import '../controllers/project_controlller.dart';

class ProjectForm extends StatefulWidget {
  final String? ownerId;
  final String? projectId;

  const ProjectForm({super.key, this.ownerId, this.projectId});

  @override
  State<ProjectForm> createState() => _ProjectFormState();
}

class _ProjectFormState extends State<ProjectForm> {
  late final ProjectController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = ProjectController(
      ownerId: widget.ownerId,
      projectId: widget.projectId,
    );
    _loadProjectIfNeeded();
  }

  Future<void> _loadProjectIfNeeded() async {
    if (widget.projectId != null && widget.projectId!.isNotEmpty) {
      await _controller.loadProject();
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _updateFormState([String? newValue]) {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    return Form(
      key: _controller.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _controller.isEditMode ? "Edit Project" : "Add New Project",
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
          ValueListenableBuilder<String>(
            valueListenable: _controller.category,
            builder: (context, value, _) {
              return DropdownButtonFormField<String>(
                initialValue: value,
                decoration: InputDecoration(
                  labelText: "Category",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: _controller.categoryOptions
                    .map(
                      (category) => DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      ),
                    )
                    .toList(),
                onChanged: (selected) {
                  if (selected != null) {
                    setState(() {
                      _controller.category.value = selected;
                    });
                  }
                },
              );
            },
          ),
          const SizedBox(height: 14),
          ValueListenableBuilder<String>(
            valueListenable: _controller.status,
            builder: (context, value, _) {
              return DropdownButtonFormField<String>(
                initialValue: value,
                decoration: InputDecoration(
                  labelText: "Status",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: _controller.statusOptions
                    .map(
                      (entry) => DropdownMenuItem(
                        value: entry,
                        child: Text(entry[0].toUpperCase() + entry.substring(1)),
                      ),
                    )
                    .toList(),
                onChanged: (selected) {
                  if (selected != null) {
                    setState(() {
                      _controller.status.value = selected;
                    });
                  }
                },
              );
            },
          ),
          const SizedBox(height: 12),
          _controller.buildTextField(
            "Expected ROI (%)",
            _controller.roiController,
            type: TextInputType.number,
          ),
          _controller.buildTextField(
            "Available Percentage (%)",
            _controller.percentageController,
            type: TextInputType.number,
            hintText: "Optional",
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return null;
              }
              final parsed = double.tryParse(value);
              if (parsed == null || parsed < 0 || parsed > 100) {
                return "Enter a value between 0 and 100";
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _controller.isLoading
                ? null
                : () async {
                    setState(() {});
                    await _controller.saveProject(context);
                    setState(() {});
                  },
            child: _controller.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(_controller.isEditMode ? "Update Project" : "Save Project"),
          ),
        ],
      ),
    );
  }
}