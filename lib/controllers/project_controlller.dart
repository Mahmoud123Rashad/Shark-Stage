import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
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

  final ValueNotifier<String> saleType = ValueNotifier<String>('Full');

  final ImagePicker _picker = ImagePicker();
  final String? ownerId;

  File? projectImage;
  File? pdfFile;
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

  Future<void> pickPdf(BuildContext context, VoidCallback onUpdate) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null && result.files.single.path != null) {
      pdfFile = File(result.files.single.path!);
      onUpdate();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF selected')),
      );
    }
  }

  Widget buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType type = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: type,
        maxLines: maxLines,
        validator: (value) =>
            (value == null || value.isEmpty) ? "Required" : null,
        decoration: InputDecoration(
          labelText: label,
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

  Widget buildPdfUploader(BuildContext context, VoidCallback onUpdate) {
    return ElevatedButton(
      onPressed: () => pickPdf(context, onUpdate),
      child: Text(
        pdfFile == null
            ? "Upload Project PDF"
            : "PDF Selected: ${pdfFile!.path.split('/').last}",
      ),
    );
  }

  Widget buildSaleTypeDropdown(
    BuildContext context,
    void Function(String) onUpdate,
  ) {
    return DropdownButtonFormField<String>(
      value: saleType.value,
      items: const [
        DropdownMenuItem(value: 'Full', child: Text("Sell Full Project")),
        DropdownMenuItem(value: 'Partial', child: Text("Sell Part of Project")),
      ],
      onChanged: (value) {
        if (value != null) {
          saleType.value = value;
          onUpdate(value);
        }
      },
      decoration: const InputDecoration(labelText: "Sale Type"),
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

    final payload = <String, dynamic>{
      "title": titleController.text.trim(),
      "shortDesc": shortDescController.text.trim(),
      "description": detailsController.text.trim(),
      "totalPrice": totalPrice,
      "owner": resolvedOwnerId,
      "status": "active",
      "expectedROI": 15,
      "availablePercentage": saleType.value == 'Partial'
          ? int.tryParse(percentageController.text.trim()) ?? 100
          : 100,
      "category": {
        "en": "Technology",
        "ar": "تكنولوجيا",
      },
      "potentialRisks": [],
      "keyBenefits": [],
      "managementTeam": [],
    };

    try {
      isLoading = true;
      final response = await ApiService.post(
        'projects/add',
        body: payload,
        auth: true,
      );
      final status = response['status'] as int? ?? 500;
      if (status == 201 && response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Project added successfully")),
        );
        formKey.currentState?.reset();
        titleController.clear();
        shortDescController.clear();
        detailsController.clear();
        priceController.clear();
        percentageController.clear();
        saleType.value = 'Full';
        projectImage = null;
        pdfFile = null;
      } else {
        final message = response['message'] ??
            response['error'] ??
            'Failed to add project';
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
