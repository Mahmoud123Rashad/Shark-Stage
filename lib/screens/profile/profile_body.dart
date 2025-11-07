// lib/screens/profile/profile_body.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_colors.dart';
import '../edit_profile_screen.dart';
import 'profile_info_card.dart';
import 'profile_service.dart';

class ProfileBody extends StatefulWidget {
  final String email;
  const ProfileBody({super.key, required this.email});

  @override
  State<ProfileBody> createState() => _ProfileBodyState();
}

class _ProfileBodyState extends State<ProfileBody> {
  String firstName = '';
  String lastName = '';
  String email = '';
  String phone = '';
  String? profilePicUrl;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    final data = await ProfileService.fetchProfile(widget.email);
    if (data != null && mounted) {
      setState(() {
        firstName = data['firstName'] ?? '';
        lastName = data['lastName'] ?? '';
        email = data['email'] ?? widget.email;
        phone = data['phone'] ?? '';
        profilePicUrl = data['profilePicUrl'];
        isLoading = false;
      });
    }
  }

  Future<void> _pickAndUploadImage() async {
    final newImageUrl = await ProfileService.pickAndUploadImage(context);
    if (newImageUrl != null && mounted) {
      setState(() => profilePicUrl = newImageUrl);
    }
  }

  Future<void> _navigateToEditProfile() async {
    final updatedData = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(
          firstName: firstName,
          lastName: lastName,
          email: email,
          phone: phone,
        ),
      ),
    );

    if (updatedData != null && mounted) {
      setState(() {
        firstName = updatedData['firstName'] ?? firstName;
        lastName = updatedData['lastName'] ?? lastName;
        phone = updatedData['phone'] ?? phone;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Column(
                children: [
                  // 🔹 صورة الملف الشخصي
                  Center(
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 65,
                          backgroundImage: profilePicUrl != null
                              ? NetworkImage(profilePicUrl!)
                              : const AssetImage("images/profile.jpeg")
                                  as ImageProvider,
                        ),
                        Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.camera_alt,
                              color: Colors.blueAccent,
                            ),
                            onPressed: _pickAndUploadImage,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // 🔹 بيانات المستخدم
                  ProfileInfoCard(label: "First Name", value: firstName),
                  const SizedBox(height: 16),
                  ProfileInfoCard(label: "Last Name", value: lastName),
                  const SizedBox(height: 16),
                  ProfileInfoCard(label: "Email", value: email),
                  const SizedBox(height: 16),
                  ProfileInfoCard(
                      label: "Phone",
                      value: phone.isNotEmpty ? phone : "Not set yet"),

                  const SizedBox(height: 40),

                  // 🔹 زر تعديل الملف
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.button,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.edit, color: Colors.white),
                      label: const Text(
                        "Edit Profile",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: _navigateToEditProfile,
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}
