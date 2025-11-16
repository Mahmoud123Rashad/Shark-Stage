import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/api_service.dart';
import '../services/auth_storage.dart';

class ProjectController {
  ProjectController({this.ownerId, this.projectId, this.initialData});

  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final shortDescController = TextEditingController();
  final detailsController = TextEditingController();
  final priceController = TextEditingController();
  final percentageController = TextEditingController();
  final roiController = TextEditingController();

  static const List<String> _categoryOptions = [
    'Technology',
    'E-Commerce',
    'Food',
    'Health',
    'Education',
    'Real Estate',
    'Industrial',
    'Other',
  ];

  static const List<String> _statusOptions = ['active', 'closed'];

  final ValueNotifier<String> category =
      ValueNotifier<String>(_categoryOptions.first);
  final ValueNotifier<String> status =
      ValueNotifier<String>(_statusOptions.first);

  final ImagePicker _picker = ImagePicker();
  final String? ownerId;
  final String? projectId;
  final Map<String, dynamic>? initialData;

  File? projectImage;
  String? existingImageUrl;
  bool isLoading = false;
  bool get isEditMode => projectId != null && projectId!.isNotEmpty;

  Future<String?> _resolveOwnerId() async {
    if (ownerId != null && ownerId!.isNotEmpty) {
      return ownerId;
    }
    final summary = await AuthStorage.getUserSummary();
    return summary['id'];
  }

  Future<void> pickImage(BuildContext context, VoidCallback onUpdate) async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      projectImage = File(picked.path);
      onUpdate();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image selected')),
      );
    }
  }

  List<String> get categoryOptions => List.unmodifiable(_categoryOptions);
  List<String> get statusOptions => List.unmodifiable(_statusOptions);

  Widget buildTextField(
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
        final fieldIcon = icon ?? _getIconForLabel(label);

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
            validator: validator ??
                (value) => (value == null || value.isEmpty) ? "Required" : null,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              prefixIcon: fieldIcon != null
                  ? Container(
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
                    )
                  : null,
              labelText: label,
              hintText: hintText,
              labelStyle: TextStyle(
                color: colorScheme.onSurface.withOpacity(0.6),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              hintStyle: TextStyle(
                color: colorScheme.onSurface.withOpacity(0.5),
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
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(
                  color: colorScheme.error,
                  width: 2,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(
                  color: colorScheme.error,
                  width: 2,
                ),
              ),
              errorStyle: TextStyle(
                color: colorScheme.error,
                fontSize: 12,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
            ),
          ),
        );
      },
    );
  }

  IconData? _getIconForLabel(String label) {
    final lowerLabel = label.toLowerCase();
    if (lowerLabel.contains('title')) return Icons.title;
    if (lowerLabel.contains('description') || lowerLabel.contains('desc')) {
      return Icons.description;
    }
    if (lowerLabel.contains('price') || lowerLabel.contains('cost')) {
      return Icons.attach_money;
    }
    if (lowerLabel.contains('roi') || lowerLabel.contains('return')) {
      return Icons.trending_up;
    }
    if (lowerLabel.contains('percentage') || lowerLabel.contains('%')) {
      return Icons.percent;
    }
    if (lowerLabel.contains('detail')) return Icons.article;
    return null;
  }

  Widget buildImagePicker(BuildContext context, VoidCallback onUpdate) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        final colorScheme = theme.colorScheme;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          height: 200,
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
              color: colorScheme.primary.withOpacity(0.2),
              width: 2,
              style: BorderStyle.solid,
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
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => pickImage(context, onUpdate),
              borderRadius: BorderRadius.circular(20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: projectImage != null
                    ? Image.file(
                        projectImage!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      )
                    : existingImageUrl != null && existingImageUrl!.isNotEmpty
                        ? Image.network(
                            existingImageUrl!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (context, error, stackTrace) =>
                                _buildImagePlaceholder(colorScheme),
                          )
                        : _buildImagePlaceholder(colorScheme),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildImagePlaceholder(ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.surfaceVariant.withOpacity(0.3),
            colorScheme.surfaceVariant.withOpacity(0.5),
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate,
            size: 48,
            color: colorScheme.primary.withOpacity(0.6),
          ),
          const SizedBox(height: 12),
          Text(
            "Tap to pick image",
            style: TextStyle(
              color: colorScheme.onSurface.withOpacity(0.6),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> loadProject() async {
    if (projectId == null || projectId!.isEmpty) return;

    try {
      isLoading = true;
      final response = await ApiService.get('projects/$projectId', auth: true);
      final statusCode = response['status'] as int? ?? 500;
      
      if (statusCode == 200 && response['success'] == true) {
        final project = response['project'] as Map<String, dynamic>?;
        if (project != null) {
          titleController.text = project['title']?.toString() ?? '';
          shortDescController.text = project['shortDesc']?.toString() ?? '';
          detailsController.text = project['description']?.toString() ?? '';
          priceController.text = (project['totalPrice'] as num?)?.toString() ?? '';
          percentageController.text = (project['availablePercentage'] as num?)?.toString() ?? '';
          roiController.text = (project['expectedROI'] as num?)?.toString() ?? '';
          
          final categoryData = project['category'];
          if (categoryData is Map && categoryData['en'] != null) {
            final catValue = categoryData['en'].toString();
            if (_categoryOptions.contains(catValue)) {
              category.value = catValue;
            }
          }
          
          final statusValue = project['status']?.toString() ?? 'active';
          if (_statusOptions.contains(statusValue)) {
            status.value = statusValue;
          }
          
          existingImageUrl = project['image']?.toString();
        }
      }
    } catch (e) {
      print("Error loading project: $e");
    } finally {
      isLoading = false;
    }
  }

  Future<void> saveProject(BuildContext context) async {
    if (isEditMode) {
      await updateProject(context);
    } else {
      await _addProject(context);
    }
  }

  Future<void> _addProject(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;

    final resolvedOwnerId = await _resolveOwnerId();
    if (resolvedOwnerId == null || resolvedOwnerId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Unable to determine owner account.")),
      );
      return;
    }

    final parsedPrice = double.tryParse(priceController.text.trim());
    final totalPrice =
        parsedPrice != null && parsedPrice >= 0 ? parsedPrice : 0.0;

    final parsedRoi = double.tryParse(roiController.text.trim());
    if (parsedRoi == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Expected ROI must be a number.")),
      );
      return;
    }

    final fields = <String, String>{
      "title": titleController.text.trim(),
      "shortDesc": shortDescController.text.trim(),
      "description": detailsController.text.trim(),
      "totalPrice": totalPrice.toString(),
      "owner": resolvedOwnerId,
      "status": status.value,
      "expectedROI": parsedRoi.toString(),
      "category": jsonEncode({"en": category.value}),
    };

    final availablePercentageText = percentageController.text.trim();
    if (availablePercentageText.isNotEmpty) {
      final parsedPercentage = double.tryParse(availablePercentageText);
      if (parsedPercentage == null || parsedPercentage < 0 || parsedPercentage > 100) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Available percentage must be between 0 and 100."),
          ),
        );
        return;
      }
      fields["availablePercentage"] = parsedPercentage.toString();
    }

    final files = <String, File>{};
    if (projectImage != null) {
      files["image"] = projectImage!;
    }

    try {
      isLoading = true;
      final response = await ApiService.postMultipart(
        'projects/add',
        fields: fields,
        files: files.isNotEmpty ? files : null,
        auth: true,
      );
      final statusCode = response['status'] as int? ?? 500;
      if (statusCode == 201 && response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Project added successfully")),
        );
        formKey.currentState?.reset();
        titleController.clear();
        shortDescController.clear();
        detailsController.clear();
        priceController.clear();
        percentageController.clear();
        roiController.clear();
        category.value = _categoryOptions.first;
        status.value = _statusOptions.first;
        projectImage = null;
      } else {
        final message = response['message'] ??
            response['error'] ??
            'Failed to add project (status $statusCode)';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message.toString())),
        );
      }
    } on TimeoutException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error: Connection timeout. Check server status."),
        ),
      );
    } catch (e) {
      final errorMsg = e is IOException
          ? "Network Error: Cannot connect to server."
          : e.toString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $errorMsg")),
      );
    } finally {
      isLoading = false;
    }
  }

  Future<void> updateProject(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;
    if (projectId == null || projectId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Project ID is missing.")),
      );
      return;
    }

    final parsedPrice = double.tryParse(priceController.text.trim());
    final totalPrice =
        parsedPrice != null && parsedPrice >= 0 ? parsedPrice : 0.0;

    final parsedRoi = double.tryParse(roiController.text.trim());
    if (parsedRoi == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Expected ROI must be a number.")),
      );
      return;
    }

    final fields = <String, String>{
      "title": titleController.text.trim(),
      "shortDesc": shortDescController.text.trim(),
      "description": detailsController.text.trim(),
      "totalPrice": totalPrice.toString(),
      "status": status.value,
      "expectedROI": parsedRoi.toString(),
      "category": jsonEncode({"en": category.value}),
    };

    final availablePercentageText = percentageController.text.trim();
    if (availablePercentageText.isNotEmpty) {
      final parsedPercentage = double.tryParse(availablePercentageText);
      if (parsedPercentage == null || parsedPercentage < 0 || parsedPercentage > 100) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Available percentage must be between 0 and 100."),
          ),
        );
        return;
      }
      fields["availablePercentage"] = parsedPercentage.toString();
    }

    final files = <String, File>{};
    if (projectImage != null) {
      files["image"] = projectImage!;
    }

    try {
      isLoading = true;
      final response = await ApiService.putMultipart(
        'projects/edit/$projectId',
        fields: fields,
        files: files.isNotEmpty ? files : null,
        auth: true,
      );
      final statusCode = response['status'] as int? ?? 500;
      if (statusCode == 200 && response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Project updated successfully")),
        );
        Navigator.of(context).pop(true); // Return true to indicate success
      } else {
        final message = response['message'] ??
            response['error'] ??
            'Failed to update project (status $statusCode)';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message.toString())),
        );
      }
    } on TimeoutException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error: Connection timeout. Check server status."),
        ),
      );
    } catch (e) {
      final errorMsg = e is IOException
          ? "Network Error: Cannot connect to server."
          : e.toString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $errorMsg")),
      );
    } finally {
      isLoading = false;
    }
  }

  Future<bool> deleteProject(BuildContext context) async {
    if (projectId == null || projectId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Project ID is missing.")),
      );
      return false;
    }

    try {
      isLoading = true;
      final success = await ApiService.delete(
        'projects/delete/$projectId',
        auth: true,
      );
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Project deleted successfully")),
        );
        return true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to delete project")),
        );
        return false;
      }
    } on TimeoutException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error: Connection timeout. Check server status."),
        ),
      );
      return false;
    } catch (e) {
      final errorMsg = e is IOException
          ? "Network Error: Cannot connect to server."
          : e.toString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $errorMsg")),
      );
      return false;
    } finally {
      isLoading = false;
    }
  }
}
