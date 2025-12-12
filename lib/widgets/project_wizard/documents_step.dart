import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class DocumentsStep extends StatefulWidget {
  final Map<String, dynamic> formData;
  final Function(Map<String, dynamic>) updateFormData;

  const DocumentsStep({
    super.key,
    required this.formData,
    required this.updateFormData,
  });

  @override
  State<DocumentsStep> createState() => _DocumentsStepState();
}

class _DocumentsStepState extends State<DocumentsStep> {
  List<Map<String, dynamic>> _documents = [];

  @override
  void initState() {
    super.initState();
    _documents = List<Map<String, dynamic>>.from(widget.formData['documents'] ?? []);
  }

  void _updateFormData() {
    widget.updateFormData({'documents': _documents});
  }

  Future<void> _pickDocuments() async {
    if (_documents.length >= 3) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Maximum 3 documents allowed'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final newDocs = <Map<String, dynamic>>[];
        for (var file in result.files) {
          if (_documents.length + newDocs.length >= 3) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Maximum 3 documents allowed'),
                  backgroundColor: Colors.red,
                ),
              );
            }
            break;
          }

          if (file.path != null) {
            final fileObj = File(file.path!);
            if (fileObj.lengthSync() > 2 * 1024 * 1024) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${file.name} is larger than 2MB'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
              continue;
            }

            newDocs.add({
              'file': fileObj,
              'title': file.name.replaceAll('.pdf', ''),
              'name': file.name,
            });
          }
        }

        setState(() {
          _documents.addAll(newDocs);
          _updateFormData();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking files: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _removeDocument(int index) {
    setState(() {
      _documents.removeAt(index);
      _updateFormData();
    });
  }

  void _updateDocumentTitle(int index, String title) {
    setState(() {
      _documents[index]['title'] = title;
      _updateFormData();
    });
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Project Documents (Optional)',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Upload up to 3 PDF documents (max 2MB each) to provide additional information about your project.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),

          // Add Documents Button
          if (_documents.length < 3)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _pickDocuments,
                icon: const Icon(Icons.upload_file),
                label: const Text('Add Documents'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 16),

          // Documents List
          if (_documents.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.folder_outlined,
                      size: 64,
                      color: colorScheme.onSurface.withOpacity(0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No documents added yet',
                      style: TextStyle(
                        color: colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...List.generate(_documents.length, (index) {
              final doc = _documents[index];
              final file = doc['file'] as File;
              final title = doc['title'] as String;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Icon(
                    Icons.description,
                    color: colorScheme.primary,
                    size: 32,
                  ),
                  title: TextFormField(
                    initialValue: title,
                    decoration: const InputDecoration(
                      labelText: 'Document Title',
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (value) => _updateDocumentTitle(index, value),
                  ),
                  subtitle: Text(
                    '${doc['name']} • ${_formatFileSize(file.lengthSync())}',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeDocument(index),
                  ),
                ),
              );
            }),

          if (_documents.length > 0 && _documents.length < 3)
            const SizedBox(height: 16),
          if (_documents.length > 0 && _documents.length < 3)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _pickDocuments,
                icon: const Icon(Icons.add),
                label: const Text('Add More Documents'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

