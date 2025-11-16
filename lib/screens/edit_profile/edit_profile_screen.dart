import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../theme/app_colors.dart';
import 'edit_profile_services.dart';
import 'edit_profile_widgets.dart';

class EditProfileScreen extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final File? image;
  final String? imageUrl;

  const EditProfileScreen({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    this.image,
    this.imageUrl,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  File? _selectedImage;
  bool _isLoading = false;
  bool _isUploadingImage = false;
  String? _currentImageUrl;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.firstName);
    _lastNameController = TextEditingController(text: widget.lastName);
    _emailController = TextEditingController(text: widget.email);
    _phoneController = TextEditingController(text: widget.phone);
    _selectedImage = widget.image;
    _currentImageUrl = widget.imageUrl;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a Photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );

    if (source != null) {
      final picked = await picker.pickImage(source: source, imageQuality: 85);
      if (picked != null && mounted) {
        setState(() {
          _selectedImage = File(picked.path);
          _currentImageUrl = null; // Clear network image when local image is selected
        });
      }
    }
  }

  String? _validateName(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    if (value.trim().length < 2) {
      return '$fieldName must be at least 2 characters';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    // Basic phone validation
    final phoneRegex = RegExp(r'^[0-9+\-\s()]+$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _isUploadingImage = _selectedImage != null;
    });

    try {
      final result = await EditProfileService.updateProfile(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        image: _selectedImage,
        onImageUploadProgress: (progress) {
          if (mounted) {
            setState(() {
              // Progress callback for future use
            });
          }
        },
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _isUploadingImage = false;
      });

      if (result.containsKey('error')) {
        _showSnack(result['error'] ?? "Unknown error", isError: true);
      } else {
        Navigator.pop(context, {
          'firstName': result['firstName'],
          'lastName': result['lastName'],
          'email': result['email'],
          'phone': result['phone'],
          'image': _selectedImage,
          'imageUrl': result['profilePicUrl'],
        });
        _showSnack("Profile updated successfully", isError: false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _isUploadingImage = false;
      });
      _showSnack("Error: ${e.toString()}", isError: true);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(msg)),
          ],
        ),
        backgroundColor: isError
            ? Colors.red.withOpacity(0.9)
            : Colors.green.withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: Duration(seconds: isError ? 4 : 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const gradient = LinearGradient(
      colors: [Color(0xFF0D1117), Color(0xFF161B22)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Edit Profile"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: gradient),
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 16),
                  ProfileImagePicker(
                    image: _selectedImage,
                    imageUrl: _currentImageUrl,
                    onPick: _pickImage,
                    isUploading: _isUploadingImage,
                  ),
                  const SizedBox(height: 30),
                  CustomTextField(
                    label: "First Name",
                    controller: _firstNameController,
                    icon: Icons.person,
                    validator: (value) => _validateName(value, "First name"),
                  ),
                  CustomTextField(
                    label: "Last Name",
                    controller: _lastNameController,
                    icon: Icons.person_outline,
                    validator: (value) => _validateName(value, "Last name"),
                  ),
                  CustomTextField(
                    label: "Email",
                    controller: _emailController,
                    icon: Icons.email,
                    readOnly: true,
                  ),
                  CustomTextField(
                    label: "Phone",
                    controller: _phoneController,
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                    validator: _validatePhone,
                  ),
                  const SizedBox(height: 35),
                  _isLoading
                      ? Column(
                          children: [
                            const CircularProgressIndicator(),
                            if (_isUploadingImage) ...[
                              const SizedBox(height: 12),
                              Text(
                                "Uploading image...",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ],
                        )
                      : SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.save, color: Colors.white),
                            label: const Text(
                              "Save Changes",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.button,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _saveProfile,
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
