import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// استيراد الـ Services المركزية
import '../../services/api_service.dart';
import '../../services/auth_storage.dart';
import 'profile/profile_service.dart';

class EditProfileScreen extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String? imageUrl;

  const EditProfileScreen({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
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

  File? _selectedImage;
  String? _currentImageUrl;
  bool _isLoading = false;
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.firstName);
    _lastNameController = TextEditingController(text: widget.lastName);
    _emailController = TextEditingController(text: widget.email);
    _phoneController = TextEditingController(text: widget.phone);
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

  /// اختيار الصورة من المعرض
  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  /// رفع الصورة أولاً إذا تم اختيار واحدة جديدة
  Future<String?> _uploadImageIfSelected() async {
    if (_selectedImage == null) return _currentImageUrl;

    setState(() => _isUploadingImage = true);

    try {
      final result = await ProfileService.uploadProfileImage(_selectedImage!);
      
      if (result['success'] == true && result['imageUrl'] != null) {
        _showSnack("✅ Profile picture uploaded successfully");
        return result['imageUrl'].toString();
      } else {
        _showSnack(result['message'] ?? "❌ Failed to upload image");
        return _currentImageUrl;
      }
    } catch (e) {
      debugPrint("❌ Image upload error: $e");
      _showSnack("Error uploading image");
      return _currentImageUrl;
    } finally {
      if (mounted) {
        setState(() => _isUploadingImage = false);
      }
    }
  }

  /// حفظ بيانات الملف الشخصي
  Future<void> _saveProfile() async {
    if (_isLoading || _isUploadingImage) return;

    // التحقق من الحقول المطلوبة
    if (_firstNameController.text.trim().isEmpty ||
        _lastNameController.text.trim().isEmpty) {
      _showSnack("⚠️ First name and last name are required");
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. رفع الصورة أولاً إذا تم تحديد واحدة جديدة
      final uploadedImageUrl = await _uploadImageIfSelected();

      // 2. تحديث بيانات المستخدم
      final response = await ApiService.put(
        'auth/update',
        {
          'firstName': _firstNameController.text.trim(),
          'lastName': _lastNameController.text.trim(),
          'phone': _phoneController.text.trim(),
        },
        auth: true,
      );

      if (response['status'] == 200 || response['status'] == 201) {
        final updatedUser = response['user'] ?? {};

        // تحديث البيانات المخزنة محلياً
        await AuthStorage.saveUser({
          ...updatedUser,
          'firstName': _firstNameController.text.trim(),
          'lastName': _lastNameController.text.trim(),
          'phone': _phoneController.text.trim(),
          if (uploadedImageUrl != null) 'profilePicUrl': uploadedImageUrl,
        });

        _showSnack("✅ Profile updated successfully");

        // الانتظار قليلاً قبل العودة لضمان ظهور الرسالة
        await Future.delayed(const Duration(milliseconds: 500));

        if (mounted) {
          Navigator.pop(context, true);
        }
      } else {
        _showSnack(response['message'] ?? "❌ Failed to update profile");
      }
    } catch (e) {
      debugPrint("❌ Update profile error: $e");
      _showSnack("Error occurred while updating profile");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: theme.colorScheme.primary.withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// تحديد مصدر الصورة بناءً على الحالة
  ImageProvider _resolveImageProvider() {
    if (_selectedImage != null) {
      return FileImage(_selectedImage!);
    } else if (_currentImageUrl != null && _currentImageUrl!.isNotEmpty) {
      return NetworkImage(_currentImageUrl!);
    } else {
      return const AssetImage('images/profile.jpeg');
    }
  }

  /// بناء حقل الإدخال المتكيف مع الثيم
  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool readOnly = false,
    TextInputType? keyboardType,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        keyboardType: keyboardType,
        style: TextStyle(color: colorScheme.onBackground),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: colorScheme.onBackground.withOpacity(0.7)),
          labelText: label,
          labelStyle: TextStyle(color: colorScheme.onBackground.withOpacity(0.7)),
          filled: true,
          fillColor: isDark ? Colors.white10 : Colors.grey.shade200,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorScheme.onBackground.withOpacity(0.06)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorScheme.primary, width: 1.6),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorScheme.onBackground.withOpacity(0.06)),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text("Edit Profile", style: theme.textTheme.titleLarge),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : Colors.black,
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF0D1117), const Color(0xFF161B22)]
                : [Colors.white, Colors.grey.shade50],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                // صورة الملف الشخصي مع زر الكاميرا
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 65,
                      backgroundImage: _resolveImageProvider(),
                      backgroundColor: isDark ? colorScheme.surface : Colors.grey.shade300,
                    ),
                    if (_isUploadingImage)
                      const Positioned.fill(
                        child: CircleAvatar(
                          backgroundColor: Colors.black45,
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      ),
                    Positioned(
                      bottom: 0,
                      right: 4,
                      child: InkWell(
                        onTap: _isUploadingImage ? null : _pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colorScheme.primary,
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                
                // حقول الإدخال
                _buildTextField("First Name", _firstNameController, Icons.person),
                _buildTextField("Last Name", _lastNameController, Icons.person_outline),
                _buildTextField("Email", _emailController, Icons.email, readOnly: true),
                _buildTextField(
                  "Phone",
                  _phoneController,
                  Icons.phone,
                  keyboardType: TextInputType.phone,
                ),
                
                const SizedBox(height: 35),
                
                // زر الحفظ
                (_isLoading || _isUploadingImage)
                    ? const CircularProgressIndicator()
                    : SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.save, color: Colors.white),
                          label: const Text(
                            "Save Changes",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: Colors.white,
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
    );
  }
}