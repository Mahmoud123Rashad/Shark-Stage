import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class BasicInfoStep extends StatefulWidget {
  final Map<String, dynamic> formData;
  final Function(Map<String, dynamic>) updateFormData;

  const BasicInfoStep({
    super.key,
    required this.formData,
    required this.updateFormData,
  });

  @override
  State<BasicInfoStep> createState() => _BasicInfoStepState();
}

class _BasicInfoStepState extends State<BasicInfoStep> {
  final _titleController = TextEditingController();
  final _shortDescController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.formData['title'] ?? '';
    _shortDescController.text = widget.formData['shortDesc'] ?? '';
    _descriptionController.text = widget.formData['description'] ?? '';
    _titleController.addListener(_updateFormData);
    _shortDescController.addListener(_updateFormData);
    _descriptionController.addListener(_updateFormData);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _shortDescController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _updateFormData() {
    widget.updateFormData({
      'title': _titleController.text,
      'shortDesc': _shortDescController.text,
      'description': _descriptionController.text,
    });
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final file = File(picked.path);
      if (file.lengthSync() > 10 * 1024 * 1024) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image size should be less than 10MB'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
      setState(() {
        widget.updateFormData({
          'imageFile': file,
          'imagePreview': picked.path,
        });
      });
    }
  }

  void _removeImage() {
    setState(() {
      widget.updateFormData({
        'imageFile': null,
        'imagePreview': null,
      });
    });
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

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType type = TextInputType.text,
    int maxLines = 1,
    String? hintText,
    String? Function(String?)? validator,
    IconData? icon,
  }) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        final colorScheme = theme.colorScheme;
        final fieldIcon = icon ?? Icons.text_fields;

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
          child: TextFormField(
            controller: controller,
            keyboardType: type,
            maxLines: maxLines,
            decoration: InputDecoration(
              prefixIcon: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  fieldIcon,
                  color: colorScheme.primary,
                  size: 20,
                ),
              ),
              labelText: label,
              hintText: hintText,
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
            validator: validator,
          ),
        );
      },
    );
  }

  Widget _buildDropdown(
    String label,
    String value,
    List<String> items,
    Function(String?) onChanged,
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
        value: value,
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
        items: items.map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text(item[0].toUpperCase() + item.substring(1)),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final imagePreview = widget.formData['imagePreview'];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Project Image', Icons.image, theme),

          // Image Picker
          Text(
            'Project Image',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          if (imagePreview != null)
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(imagePreview),
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: _removeImage,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black54,
                    ),
                  ),
                ),
              ],
            )
          else
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.primary.withOpacity(0.3),
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image,
                      size: 48,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap to select image',
                      style: TextStyle(
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 12),

          _buildSectionTitle('Basic Information', Icons.info_outline, theme),
          _buildTextField(
            'Project Title *',
            _titleController,
            icon: Icons.title,
            hintText: 'Enter project title',
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter project title';
              }
              return null;
            },
          ),
          _buildTextField(
            'Short Description *',
            _shortDescController,
            icon: Icons.description,
            maxLines: 2,
            hintText: 'Brief description of your project',
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter short description';
              }
              return null;
            },
          ),
          _buildTextField(
            'Full Description *',
            _descriptionController,
            icon: Icons.article,
            maxLines: 5,
            hintText: 'Detailed description of your project',
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter full description';
              }
              return null;
            },
          ),

          _buildSectionTitle('Category & Status', Icons.category, theme),
          _buildDropdown(
            'Category *',
            widget.formData['category'] ?? 'Technology',
            const [
              'Technology',
              'E-Commerce',
              'Food',
              'Health',
              'Education',
              'Real Estate',
              'Industrial',
              'Other',
            ],
            (value) {
              if (value != null) {
                widget.updateFormData({'category': value});
              }
            },
            Icons.category,
            theme,
          ),
          _buildDropdown(
            'Status *',
            widget.formData['status'] ?? 'active',
            const ['active', 'closed'],
            (value) {
              if (value != null) {
                widget.updateFormData({'status': value});
              }
            },
            Icons.flag,
            theme,
          ),
        ],
      ),
    );
  }
}

