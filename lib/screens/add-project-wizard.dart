import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:finial_project/screens/payment/project_payment_form.dart';
import 'package:finial_project/screens/project_details/project_details_screen.dart';
import '../widgets/project_wizard/step_indicator.dart';
import '../widgets/project_wizard/basic_info_step.dart';
import '../widgets/project_wizard/financial_step.dart';
import '../widgets/project_wizard/details_step.dart';
import '../widgets/project_wizard/documents_step.dart';
import '../widgets/project_wizard/review_step.dart';
import '../widgets/project/add_project_hero_section.dart';
import '../services/api_service.dart';
import '../services/auth_storage.dart';
import '../theme/app_colors.dart';

class AddProjectWizardScreen extends StatefulWidget {
  const AddProjectWizardScreen({super.key});

  @override
  State<AddProjectWizardScreen> createState() => _AddProjectWizardScreenState();
}

class _AddProjectWizardScreenState extends State<AddProjectWizardScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  bool _isLoading = false;
  String? _error;

  final List<StepData> _steps = const [
    StepData(name: 'Basic Info', icon: Icons.info_outline),
    StepData(name: 'Financial', icon: Icons.attach_money),
    StepData(name: 'Details', icon: Icons.description),
    StepData(name: 'Documents', icon: Icons.folder),
    StepData(name: 'Review', icon: Icons.check_circle),
  ];

  Map<String, dynamic> _formData = {
    'title': '',
    'shortDesc': '',
    'description': '',
    'category': 'Technology',
    'status': 'active',
    'imageFile': null,
    'imagePreview': null,
    'totalPrice': '',
    'availablePercentage': '',
    'expectedROI': '',
    'keyBenefits': [],
    'potentialRisks': [],
    'timeline': [],
    'documents': [],
  };

  bool _showPaymentForm = false;
  Map<String, dynamic>? _pendingProjectData;
  File? _pendingProjectImage;

  void _updateFormData(Map<String, dynamic> updates) {
    setState(() {
      _formData = {..._formData, ...updates};
    });
  }

  bool _validateStep(int step) {
    setState(() {
      _error = null;
    });

    switch (step) {
      case 0: // Basic Info
        if (_formData['title'] == null ||
            _formData['title'].toString().trim().isEmpty ||
            _formData['shortDesc'] == null ||
            _formData['shortDesc'].toString().trim().isEmpty ||
            _formData['description'] == null ||
            _formData['description'].toString().trim().isEmpty ||
            _formData['category'] == null ||
            _formData['category'].toString().isEmpty) {
          setState(() {
            _error = 'Please fill in all required fields';
          });
          return false;
        }
        return true;

      case 1: // Financial
        if (_formData['totalPrice'] == null ||
            _formData['totalPrice'].toString().trim().isEmpty ||
            _formData['expectedROI'] == null ||
            _formData['expectedROI'].toString().trim().isEmpty) {
          setState(() {
            _error = 'Please fill in all required financial details';
          });
          return false;
        }
        final availablePercentage = _formData['availablePercentage']?.toString();
        if (availablePercentage != null && availablePercentage.trim().isNotEmpty) {
          final parsed = double.tryParse(availablePercentage);
          if (parsed == null || parsed < 0 || parsed > 100) {
            setState(() {
              _error = 'Available percentage must be between 0-100';
            });
            return false;
          }
        }
        final roi = double.tryParse(_formData['expectedROI'].toString());
        if (roi == null || roi < 0 || roi > 100) {
          setState(() {
            _error = 'Expected ROI must be between 0-100';
          });
          return false;
        }
        return true;

      case 2: // Details - Optional
        return true;

      case 3: // Documents
        final documents = _formData['documents'] as List?;
        if (documents != null && documents.length > 3) {
          setState(() {
            _error = 'Maximum 3 documents allowed';
          });
          return false;
        }
        if (documents != null) {
          for (var doc in documents) {
            if (doc['title'] == null || doc['title'].toString().trim().isEmpty) {
              setState(() {
                _error = 'Each document must have a title';
              });
              return false;
            }
            final file = doc['file'] as File?;
            if (file != null && file.lengthSync() > 2 * 1024 * 1024) {
              setState(() {
                _error = 'Each document must be less than 2MB';
              });
              return false;
            }
          }
        }
        return true;

      default:
        return true;
    }
  }

  void _nextStep() {
    if (!mounted) return;
    
    if (_validateStep(_currentStep)) {
      if (_currentStep == 4) {
        // Show payment form
        _preparePaymentData();
      } else {
        setState(() {
          _error = null;
        });
        try {
          if (_pageController.hasClients) {
            _pageController.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          } else {
            setState(() {
              _currentStep = _currentStep + 1;
            });
          }
        } catch (e) {
          // If page controller fails, manually update step
          setState(() {
            _currentStep = _currentStep + 1;
          });
        }
      }
    }
  }

  void _previousStep() {
    if (!mounted) return;
    
    try {
      if (_currentStep > 0) {
        setState(() {
          _error = null;
        });
        if (_pageController.hasClients) {
          _pageController.previousPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        } else {
          setState(() {
            _currentStep = _currentStep - 1;
          });
        }
      }
    } catch (e) {
      // If page controller fails, manually update step
      if (_currentStep > 0) {
        setState(() {
          _currentStep = _currentStep - 1;
          _error = null;
        });
      }
    }
  }

  void _preparePaymentData() {
    setState(() {
      _pendingProjectData = {
        'title': _formData['title'],
        'shortDesc': _formData['shortDesc'],
        'description': _formData['description'],
        'totalPrice': _formData['totalPrice'],
        'availablePercentage': _formData['availablePercentage'],
        'expectedROI': _formData['expectedROI'],
        'category': _formData['category'],
        'status': _formData['status'],
        'keyBenefits': _formData['keyBenefits'],
        'potentialRisks': _formData['potentialRisks'],
        'timeline': _formData['timeline'],
        'documents': _formData['documents'],
      };
      _pendingProjectImage = _formData['imageFile'] as File?;
      _showPaymentForm = true;
    });
  }

  void _handleBackToForm() {
    setState(() {
      _showPaymentForm = false;
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
      final summary = await AuthStorage.getUserSummary();
      final ownerId = summary['id'];

      final parsedPrice =
          double.tryParse(_pendingProjectData!['totalPrice']?.toString() ?? '0');
      final totalPrice = parsedPrice != null && parsedPrice >= 0 ? parsedPrice : 0.0;

      final parsedRoi =
          double.tryParse(_pendingProjectData!['expectedROI']?.toString() ?? '0');
      if (parsedRoi == null) {
        throw Exception('Expected ROI must be a number');
      }

      final fields = <String, String>{
        'title': _pendingProjectData!['title']?.toString() ?? '',
        'shortDesc': _pendingProjectData!['shortDesc']?.toString() ?? '',
        'description': _pendingProjectData!['description']?.toString() ?? '',
        'totalPrice': totalPrice.toString(),
        'owner': ownerId.toString(),
        'status': _pendingProjectData!['status']?.toString() ?? 'active',
        'expectedROI': parsedRoi.toString(),
        'category': jsonEncode(
            {'en': _pendingProjectData!['category']?.toString() ?? ''}),
      };

      final availablePercentageText =
          _pendingProjectData!['availablePercentage']?.toString();
      if (availablePercentageText != null && availablePercentageText.isNotEmpty) {
        final parsedPercentage = double.tryParse(availablePercentageText);
        if (parsedPercentage != null &&
            parsedPercentage >= 0 &&
            parsedPercentage <= 100) {
          fields['availablePercentage'] = parsedPercentage.toString();
        }
      }

      // Key Benefits
      final keyBenefits = _pendingProjectData!['keyBenefits'] as List?;
      if (keyBenefits != null && keyBenefits.isNotEmpty) {
        final filtered = keyBenefits
            .where((b) => b.toString().trim().isNotEmpty)
            .map((b) => b.toString())
            .toList();
        if (filtered.isNotEmpty) {
          fields['keyBenefits'] = jsonEncode(filtered);
        }
      }

      // Potential Risks
      final potentialRisks = _pendingProjectData!['potentialRisks'] as List?;
      if (potentialRisks != null && potentialRisks.isNotEmpty) {
        final filtered = potentialRisks
            .where((r) => r.toString().trim().isNotEmpty)
            .map((r) => r.toString())
            .toList();
        if (filtered.isNotEmpty) {
          fields['potentialRisks'] = jsonEncode(filtered);
        }
      }

      // Timeline
      final timeline = _pendingProjectData!['timeline'] as List?;
      if (timeline != null && timeline.isNotEmpty) {
        fields['timeline'] = jsonEncode(timeline);
      }

      final files = <String, File>{};
      if (_pendingProjectImage != null) {
        files['image'] = _pendingProjectImage!;
      }

      // Documents
      final documents = _pendingProjectData!['documents'] as List?;
      List<File>? documentFiles;
      if (documents != null && documents.isNotEmpty) {
        final docTitles = documents
            .map((d) => d['title']?.toString() ?? '')
            .where((t) => t.isNotEmpty)
            .toList();
        if (docTitles.isNotEmpty) {
          fields['documentTitles'] = jsonEncode(docTitles);
        }

        documentFiles = documents
            .map((d) => d['file'] as File?)
            .where((f) => f != null)
            .cast<File>()
            .toList();
      }

      final response = await ApiService.postMultipartWithMultipleFiles(
        'projects/add',
        fields: fields,
        files: files.isNotEmpty ? files : null,
        multipleFilesField: documentFiles != null && documentFiles.isNotEmpty
            ? {'documents': documentFiles}
            : null,
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
        setState(() {
          _showPaymentForm = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _showPaymentForm = false;
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
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
        title: const Text('Add New Project'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          color: !isDark ? Colors.grey[50] : null,
          gradient: isDark
              ? const LinearGradient(
                  colors: [Color(0xFF121212), Color(0xFF1E1E1E)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                )
              : null,
        ),
        child: Stack(
          children: [
            Column(
              children: [
                // Hero Section
                AddProjectHeroSection(isEditMode: false),
                // Step Indicator
                StepIndicator(
                  steps: _steps,
                  currentStep: _currentStep,
                ),
                // Error Alert
                if (_error != null)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _error!,
                            style: TextStyle(color: Colors.red.shade700),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: () => setState(() => _error = null),
                          color: Colors.red.shade700,
                        ),
                      ],
                    ),
                  ),
                // Step Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 80), // Add bottom padding for floating buttons
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      onPageChanged: (index) {
                        setState(() {
                          _currentStep = index;
                          _error = null;
                        });
                      },
                      children: [
                        BasicInfoStep(
                          formData: _formData,
                          updateFormData: _updateFormData,
                        ),
                        FinancialStep(
                          formData: _formData,
                          updateFormData: _updateFormData,
                        ),
                        DetailsStep(
                          formData: _formData,
                          updateFormData: _updateFormData,
                        ),
                        DocumentsStep(
                          formData: _formData,
                          updateFormData: _updateFormData,
                        ),
                        ReviewStep(formData: _formData),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Floating Back Button (Left) - Only show in steps 1-4
            if (_currentStep > 0 && _currentStep < 5)
              Positioned(
                left: 16,
                bottom: 16,
                child: FloatingActionButton(
                  heroTag: 'back_button',
                  onPressed: _isLoading ? null : _previousStep,
                  backgroundColor: theme.colorScheme.surface,
                  foregroundColor: theme.colorScheme.onSurface,
                  elevation: 4,
                  child: const Icon(Icons.arrow_back),
                ),
              ),
            // Floating Next Button (Right)
            Positioned(
              right: 16,
              bottom: 16,
              child: FloatingActionButton.extended(
                heroTag: 'next_button',
                onPressed: _isLoading ? null : _nextStep,
                backgroundColor: AppColors.button,
                foregroundColor: Colors.white,
                elevation: 4,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Icon(_currentStep == 4 ? Icons.payment : Icons.arrow_forward),
                label: Text(_currentStep == 4 ? 'Proceed to Payment' : 'Next'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

