import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import "package:file_picker/file_picker.dart";
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
class Add_project extends StatefulWidget {
  const Add_project({super.key});

  @override
  _Add_projectState createState() => _Add_projectState();
}

class _Add_projectState extends State<Add_project> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _detailsController = TextEditingController();
  final _priceController = TextEditingController();
  final _percentageController = TextEditingController();

  File? _projectImage;
  File? _pdfFile;
  String saleType = 'Full';
  bool _isLoading = false;
  final picker = ImagePicker();

  // Pick image
  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _projectImage = File(pickedFile.path));
    }
  }

  // Pick PDF
  Future<void> _pickPDF() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() => _pdfFile = File(result.files.single.path!));
    }
  }

  // Save project
  Future<void> _saveProject() async {
    if (!_formKey.currentState!.validate()) return;
    if (_projectImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a project image")),
      );
      return;
    }

    final price = double.tryParse(_priceController.text.trim());
    if (price == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter a valid numeric price")),
      );
      return;
    }

    if (saleType == 'Partial') {
      final pct = int.tryParse(_percentageController.text.trim());
      if (pct == null || pct <= 0 || pct > 100) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Enter a valid percentage (1–100)")),
        );
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not authenticated");

      final imageRef = FirebaseStorage.instance.ref(
        'projects/${user.uid}/images/${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      final imageSnap = await imageRef.putFile(_projectImage!).whenComplete(() {});
      final imageUrl = await imageSnap.ref.getDownloadURL();

      String? pdfUrl;
      if (_pdfFile != null) {
        final pdfRef = FirebaseStorage.instance.ref(
          'projects/${user.uid}/pdfs/${DateTime.now().millisecondsSinceEpoch}.pdf',
        );
        final pdfSnap = await pdfRef.putFile(_pdfFile!).whenComplete(() {});
        pdfUrl = await pdfSnap.ref.getDownloadURL();
      }

      await FirebaseFirestore.instance.collection('projects').add({
        'title': _titleController.text.trim(),
        'details': _detailsController.text.trim(),
        'price': price,
        'saleType': saleType,
        'percentage': saleType == 'Partial'
            ? int.parse(_percentageController.text.trim())
            : 100,
        'imageUrl': imageUrl,
        'pdfUrl': pdfUrl ?? '',
        'ownerId': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Project saved successfully")),
      );

      _formKey.currentState!.reset();
      setState(() {
        _projectImage = null;
        _pdfFile = null;
        saleType = 'Full';
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving project: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // UI
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "Entrepreneur Dashboard",
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.appBarTheme.foregroundColor,
          ),
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(
                  colors: [Color(0xFF121212), Color(0xFF1E1E1E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : const LinearGradient(
                  colors: [Color(0xFFE3F2FD), Color(0xFFFFFFFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 100),
          child: Card(
            color: theme.cardColor,
            elevation: 10,
            shadowColor: theme.shadowColor.withOpacity(0.2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "Add New Project",
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 25),

                    // Image picker
                    GestureDetector(
                      onTap: _pickImage,
                      child: _projectImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.file(
                                _projectImage!,
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Container(
                              height: 200,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: theme.colorScheme.primary
                                      .withOpacity(0.3),
                                ),
                                color: theme.colorScheme.surfaceVariant,
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_a_photo,
                                      color: theme.colorScheme.primary,
                                      size: 40,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Tap to upload project image",
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(height: 20),

                    _buildField(
                      _titleController,
                      "Project Title",
                      Icons.title,
                      "Enter title",
                      theme,
                    ),
                    _buildField(
                      _detailsController,
                      "Project Details",
                      Icons.description,
                      "Enter details",
                      theme,
                      maxLines: 4,
                    ),
                    _buildField(
                      _priceController,
                      "Project Price",
                      Icons.monetization_on,
                      "Enter price",
                      theme,
                      type: TextInputType.number,
                    ),
                    const SizedBox(height: 12),

                    DropdownButtonFormField<String>(
                      value: saleType,
                      items: const [
                        DropdownMenuItem(
                          value: 'Full',
                          child: Text("Sell Full Project"),
                        ),
                        DropdownMenuItem(
                          value: 'Partial',
                          child: Text("Sell Part of Project"),
                        ),
                      ],
                      onChanged: (v) => setState(() => saleType = v!),
                      decoration: InputDecoration(
                        labelText: "Sale Type",
                        prefixIcon: Icon(
                          Icons.sell_outlined,
                          color: theme.colorScheme.primary,
                        ),
                        filled: true,
                        fillColor: theme.colorScheme.surfaceVariant,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    if (saleType == 'Partial')
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: _buildField(
                          _percentageController,
                          "Percentage of Project",
                          Icons.percent,
                          "Enter percentage",
                          theme,
                          type: TextInputType.number,
                        ),
                      ),
                    const SizedBox(height: 20),

                    ElevatedButton.icon(
                      onPressed: _pickPDF,
                      icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                      label: Text(
                        "Upload Project PDF",
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    if (_pdfFile != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          " ${_pdfFile!.path.split('/').last}",
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall,
                        ),
                      ),

                    const SizedBox(height: 25),
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: _saveProject,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.secondary,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Text(
                              "Save Project",
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController c,
    String label,
    IconData icon,
    String vMsg,
    ThemeData theme, {
    TextInputType type = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: c,
        keyboardType: type,
        maxLines: maxLines,
        validator: (v) => (v == null || v.isEmpty) ? vMsg : null,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: theme.colorScheme.primary),
          filled: true,
          fillColor: theme.colorScheme.surfaceVariant,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
