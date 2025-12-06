import 'dart:io';
import 'dart:convert';
import 'package:finial_project/widgets/project_form.dart';
import 'package:finial_project/screens/payment/project_payment_form.dart';
import 'package:finial_project/screens/project_details/project_details_screen.dart';
import 'package:flutter/material.dart';
import '../widgets/project/add_project_hero_section.dart';
import '../controllers/project_controlller.dart';
import '../services/api_service.dart';
import '../services/auth_storage.dart';

class AddProjectScreen extends StatefulWidget {
  final String? ownerId;
  final String? projectId;

  const AddProjectScreen({
    super.key,
    this.ownerId,
    this.projectId,
  });

  @override
  State<AddProjectScreen> createState() => _AddProjectScreenState();
}

class _AddProjectScreenState extends State<AddProjectScreen> {
  bool _showPaymentForm = false;
  Map<String, dynamic>? _pendingProjectData;
  File? _pendingProjectImage;
  bool _isLoading = false;
  String? _error;

  void _handleFormSubmit(ProjectController controller) {
    // Save project data temporarily
    setState(() {
      _pendingProjectData = {
        'title': controller.titleController.text.trim(),
        'shortDesc': controller.shortDescController.text.trim(),
        'description': controller.detailsController.text.trim(),
        'totalPrice': controller.priceController.text.trim(),
        'availablePercentage': controller.percentageController.text.trim(),
        'expectedROI': controller.roiController.text.trim(),
        'category': controller.category.value,
        'status': controller.status.value,
        'ownerId': widget.ownerId,
      };
      _pendingProjectImage = controller.projectImage;
      _showPaymentForm = true;
    });
  }

  void _handleBackToForm() {
    setState(() {
      _showPaymentForm = false;
      _pendingProjectData = null;
      _pendingProjectImage = null;
      _error = null;
    });
  }

  Future<void> _handlePaymentSuccess(Map<String, dynamic> paymentData) async {
    if (_pendingProjectData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Project data not found'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      var resolvedOwnerId = _pendingProjectData!['ownerId'];
      if (resolvedOwnerId == null || resolvedOwnerId.toString().isEmpty) {
        final summary = await AuthStorage.getUserSummary();
        resolvedOwnerId = summary['id'];
      }

      final parsedPrice = double.tryParse(_pendingProjectData!['totalPrice']?.toString() ?? '0');
      final totalPrice = parsedPrice != null && parsedPrice >= 0 ? parsedPrice : 0.0;

      final parsedRoi = double.tryParse(_pendingProjectData!['expectedROI']?.toString() ?? '0');
      if (parsedRoi == null) {
        throw Exception('Expected ROI must be a number');
      }

      final fields = <String, String>{
        'title': _pendingProjectData!['title']?.toString() ?? '',
        'shortDesc': _pendingProjectData!['shortDesc']?.toString() ?? '',
        'description': _pendingProjectData!['description']?.toString() ?? '',
        'totalPrice': totalPrice.toString(),
        'owner': resolvedOwnerId.toString(),
        'status': _pendingProjectData!['status']?.toString() ?? 'active',
        'expectedROI': parsedRoi.toString(),
        'category': jsonEncode({'en': _pendingProjectData!['category']?.toString() ?? ''}),
      };

      final availablePercentageText = _pendingProjectData!['availablePercentage']?.toString();
      if (availablePercentageText != null && availablePercentageText.isNotEmpty) {
        final parsedPercentage = double.tryParse(availablePercentageText);
        if (parsedPercentage != null && parsedPercentage >= 0 && parsedPercentage <= 100) {
          fields['availablePercentage'] = parsedPercentage.toString();
        }
      }

      final files = <String, File>{};
      if (_pendingProjectImage != null) {
        files['image'] = _pendingProjectImage!;
      }

      final response = await ApiService.postMultipart(
        'projects/add',
        fields: fields,
        files: files.isNotEmpty ? files : null,
        auth: true,
      );

      final statusCode = response['status'] as int? ?? 500;
      if (statusCode == 201 && response['success'] == true) {
        final newProjectId = response['newProjectId']?.toString();
        
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment processed and project created successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to project details
        if (newProjectId != null && newProjectId.isNotEmpty) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ProjectDetailsScreen(projectId: newProjectId),
            ),
          );
        } else {
          Navigator.pop(context);
        }
      } else {
        final message = response['message'] ?? 'Failed to create project';
        setState(() {
          _error = message.toString();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isEditMode = widget.projectId != null && widget.projectId!.isNotEmpty;

    // Show payment form if needed
    if (_showPaymentForm && _pendingProjectData != null) {
      return ProjectPaymentForm(
        projectData: _pendingProjectData!,
        projectImage: _pendingProjectImage,
        onSubmit: _handlePaymentSuccess,
        onBack: _handleBackToForm,
        loading: _isLoading,
        errors: _error != null ? {'general': _error!} : null,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? "Edit Project" : "Add Project"),
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          color: !isDark ? Colors.grey[50] : null,
          gradient: isDark
              ? const LinearGradient(
                  colors: [
                    Color(0xFF121212),
                    Color(0xFF1E1E1E),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                )
              : null,
        ),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: AddProjectHeroSection(isEditMode: isEditMode),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              sliver: SliverToBoxAdapter(
                child: ProjectForm(
                  ownerId: widget.ownerId,
                  projectId: widget.projectId,
                  onFormSubmit: isEditMode ? null : _handleFormSubmit,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
