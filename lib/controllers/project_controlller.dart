import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/api_service.dart';
import '../services/auth_storage.dart';

class ProjectController {
  ProjectController({this.ownerId});

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

  File? projectImage;
  bool isLoading = false;

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
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: type,
        maxLines: maxLines,
        validator: validator ??
            (value) => (value == null || value.isEmpty) ? "Required" : null,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget buildImagePicker(BuildContext context, VoidCallback onUpdate) {
    return GestureDetector(
      onTap: () => pickImage(context, onUpdate),
      child: Container(
        height: 150,
        color: Colors.grey.shade200,
        alignment: Alignment.center,
        child: projectImage == null
            ? const Text("Tap to pick image")
            : Image.file(projectImage!, fit: BoxFit.cover),
      ),
    );
  }

  Future<void> saveProject(BuildContext context) async {
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
}
