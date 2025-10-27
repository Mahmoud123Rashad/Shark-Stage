import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';

class EditProfileScreen extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final File? image;

  const EditProfileScreen({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    this.image,
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
  bool _isLoading = false;

  final String baseUrl = "https://sharkserver-production.up.railway.app";

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.firstName);
    _lastNameController = TextEditingController(text: widget.lastName);
    _emailController = TextEditingController(text: widget.email);
    _phoneController = TextEditingController(text: widget.phone);
    _selectedImage = widget.image;
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        _showSnack("Token not found");
        setState(() => _isLoading = false);
        return;
      }

      final uri = Uri.parse("$baseUrl/auth/update");
      var request = http.MultipartRequest('PUT', uri);

      request.fields['firstName'] = _firstNameController.text.trim();
      request.fields['lastName'] = _lastNameController.text.trim();
      request.fields['email'] = _emailController.text.trim();
      request.fields['phone'] = _phoneController.text.trim();

      if (_selectedImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'image',
          _selectedImage!.path,
        ));
      }

      request.headers['Authorization'] = 'Bearer $token';

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint("Update Status: ${response.statusCode}");
      debugPrint("Response: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final updatedUser = data['user'] ?? data;

        await prefs.setString('firstName', updatedUser['firstName'] ?? '');
        await prefs.setString('lastName', updatedUser['lastName'] ?? '');
        await prefs.setString('email', updatedUser['email'] ?? '');
        await prefs.setString('phone', updatedUser['phone'] ?? '');

        Navigator.pop(context, {
          'firstName': updatedUser['firstName'],
          'lastName': updatedUser['lastName'],
          'email': updatedUser['email'],
          'phone': updatedUser['phone'],
          'image': _selectedImage,
        });

        _showSnack("Profile updated successfully");
      } else {
        final data = jsonDecode(response.body);
        _showSnack(data['message'] ?? "Failed to update profile");
      }
    } catch (e) {
      debugPrint("Error updating profile: $e");
      _showSnack("Error occurred while updating profile");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.button.withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon,
      {bool readOnly = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.white70),
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: Colors.white.withOpacity(0.05),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.06)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.button, width: 1.6),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gradient = const LinearGradient(
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
        decoration: BoxDecoration(gradient: gradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 65,
                      backgroundImage: _selectedImage != null
                          ? FileImage(_selectedImage!)
                          : const AssetImage('images/profile.jpeg') as ImageProvider,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 4,
                      child: InkWell(
                        onTap: _pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.button,
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                _buildTextField("First Name", _firstNameController, Icons.person),
                _buildTextField("Last Name", _lastNameController, Icons.person_outline),
                _buildTextField("Email", _emailController, Icons.email, readOnly: true),
                _buildTextField("Phone", _phoneController, Icons.phone),
                const SizedBox(height: 35),
                _isLoading
                    ? const CircularProgressIndicator()
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
    );
  }
}
