import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';

class ProjectController {
  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final detailsController = TextEditingController();
  final priceController = TextEditingController();
  final percentageController = TextEditingController();

  File? projectImage;
  File? pdfFile;
  String saleType = 'Full';
  bool isLoading = false;

  final picker = ImagePicker();

  // Pick image
  Future<void> pickImage(BuildContext context) async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      projectImage = File(picked.path);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Image selected')));
    }
  }

  // Pick PDF
  Future<void> pickPdf(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null && result.files.single.path != null) {
      pdfFile = File(result.files.single.path!);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('PDF selected')));
    }
  }

  // Build fields (reusable)
  Widget buildTextField(String label, TextEditingController c,
      {TextInputType type = TextInputType.text, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: c,
        keyboardType: type,
        maxLines: maxLines,
        validator: (v) => (v == null || v.isEmpty) ? "Required" : null,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget buildImagePicker(BuildContext context) => GestureDetector(
        onTap: () => pickImage(context),
        child: Container(
          height: 150,
          color: Colors.grey.shade200,
          alignment: Alignment.center,
          child: const Text("Tap to pick image"),
        ),
      );

  Widget buildPdfUploader(BuildContext context) => ElevatedButton(
        onPressed: () => pickPdf(context),
        child: const Text("Upload Project PDF"),
      );

  Widget buildSaleTypeDropdown(BuildContext context) => DropdownButtonFormField(
        value: saleType,
        items: const [
          DropdownMenuItem(value: 'Full', child: Text("Sell Full Project")),
          DropdownMenuItem(value: 'Partial', child: Text("Sell Part of Project")),
        ],
        onChanged: (v) => saleType = v!,
        decoration: const InputDecoration(labelText: "Sale Type"),
      );

  // Save Project
  Future<void> saveProject(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;
    if (projectImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select a project image")));
      return;
    }

    final uri = Uri.parse("${ApiService.baseUrl}/projects/add");
    final request = http.MultipartRequest('POST', uri);

    request.files.add(await http.MultipartFile.fromPath('image', projectImage!.path));
    if (pdfFile != null) {
      request.files.add(await http.MultipartFile.fromPath('pdf', pdfFile!.path));
    }

    request.fields.addAll({
      "title": titleController.text.trim(),
      "shortDesc": detailsController.text.trim(),
      "description": detailsController.text.trim(),
      "totalPrice": priceController.text.trim(),
      "owner": "672a9f6d239dabc92b4d31f9",
      "status": "active",
      "expectedROI": "15",
      "availablePercentage":
          saleType == 'Partial' ? percentageController.text.trim() : "100",
      "category[en]": "Technology",
      "category[ar]": "تكنولوجيا",
    });

    try {
      final response = await request.send().timeout(const Duration(seconds: 60));
      final body = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Project added successfully")));
      } else {
        throw Exception("Server returned ${response.statusCode}: $body");
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }
}
