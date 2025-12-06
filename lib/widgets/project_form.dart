import 'package:flutter/material.dart';
import '../controllers/project_controlller.dart';

class ProjectForm extends StatefulWidget {
  final String? ownerId;
  final String? projectId;
  final Function(ProjectController)? onFormSubmit;

  const ProjectForm({
    super.key,
    this.ownerId,
    this.projectId,
    this.onFormSubmit,
  });

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

  Widget _buildSectionTitle(String title, IconData icon, ThemeData theme) {
    final colorScheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    String value,
    List<String> items,
    Function(String) onChanged,
    IconData icon,
    ThemeData theme,
  ) {
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  colorScheme.surface.withOpacity(0.6),
                  colorScheme.surface.withOpacity(0.4),
                ]
              : [
                  Colors.white,
                  colorScheme.primary.withOpacity(0.03),
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.1),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(isDark ? 0.2 : 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        decoration: InputDecoration(
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: colorScheme.primary,
              size: 20,
            ),
          ),
          labelText: label,
          labelStyle: TextStyle(
            color: colorScheme.onSurface.withOpacity(0.6),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          filled: true,
          fillColor: Colors.transparent,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(
              color: colorScheme.primary,
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
        ),
        style: theme.textTheme.bodyLarge?.copyWith(
          color: colorScheme.onSurface,
          fontSize: 16,
        ),
        items: items
            .map(
              (item) => DropdownMenuItem(
                value: item,
                child: Text(item[0].toUpperCase() + item.substring(1)),
              ),
            )
            .toList(),
        onChanged: (selected) {
          if (selected != null) {
            onChanged(selected);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Form(
      key: _controller.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Image Picker Section
          _buildSectionTitle('Project Image', Icons.image, theme),
          _controller.buildImagePicker(context, _updateFormState),

          // Basic Info Section
          _buildSectionTitle('Basic Information', Icons.info_outline, theme),
          _controller.buildTextField(
            "Project Title",
            _controller.titleController,
            icon: Icons.title,
          ),
          _controller.buildTextField(
            "Short Description",
            _controller.shortDescController,
            icon: Icons.description,
          ),
          _controller.buildTextField(
            "Details (Full Description)",
            _controller.detailsController,
            maxLines: 4,
            icon: Icons.article,
          ),

          // Category & Status Section
          _buildSectionTitle('Category & Status', Icons.category, theme),
          ValueListenableBuilder<String>(
            valueListenable: _controller.category,
            builder: (context, value, _) {
              return _buildDropdown(
                "Category",
                value,
                _controller.categoryOptions,
                (selected) {
                  setState(() {
                    _controller.category.value = selected;
                  });
                },
                Icons.category,
                theme,
              );
            },
          ),
          ValueListenableBuilder<String>(
            valueListenable: _controller.status,
            builder: (context, value, _) {
              return _buildDropdown(
                "Status",
                value,
                _controller.statusOptions,
                (selected) {
                  setState(() {
                    _controller.status.value = selected;
                  });
                },
                Icons.flag,
                theme,
              );
            },
          ),

          // Financial Info Section
          _buildSectionTitle('Financial Information', Icons.attach_money, theme),
          _controller.buildTextField(
            "Price",
            _controller.priceController,
            type: TextInputType.number,
            icon: Icons.attach_money,
          ),
          _controller.buildTextField(
            "Expected ROI (%)",
            _controller.roiController,
            type: TextInputType.number,
            icon: Icons.trending_up,
          ),
          _controller.buildTextField(
            "Available Percentage (%)",
            _controller.percentageController,
            type: TextInputType.number,
            hintText: "Optional",
            icon: Icons.percent,
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

          // Save Button
          const SizedBox(height: 32),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.primary,
                  colorScheme.secondary,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _controller.isLoading
                  ? null
                  : () async {
                      setState(() {});
                      // If onFormSubmit callback is provided, use it (for new projects with payment)
                      if (widget.onFormSubmit != null && !_controller.isEditMode) {
                        widget.onFormSubmit!(_controller);
                      } else {
                        // Otherwise, use the default save behavior
                        await _controller.saveProject(context);
                      }
                      setState(() {});
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 18,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _controller.isLoading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _controller.isEditMode
                              ? Icons.update
                              : Icons.save,
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _controller.isEditMode
                              ? "Update Project"
                              : "Save Project",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}