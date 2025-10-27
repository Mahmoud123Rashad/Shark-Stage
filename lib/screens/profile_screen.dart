import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String email;
  const ProfileScreen({super.key, required this.email});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String firstName = '';
  String lastName = '';
  String email = '';
  String phone = '';
  bool isLoading = true;

  final String baseUrl = "https://sharkserver-production.up.railway.app";

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        debugPrint(" Missing token in SharedPreferences");
        return;
      }

      final response = await http.get(
        Uri.parse("$baseUrl/auth/me"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      debugPrint(" Status Code: ${response.statusCode}");
      debugPrint("Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = data['user'] ?? {};

        setState(() {
          firstName = user['firstName'] ?? '';
          lastName = user['lastName'] ?? '';
          email = user['email'] ?? widget.email;
          phone = user['phone'] ?? '';
          isLoading = false;
        });
      } else {
        debugPrint(" Failed to fetch profile: ${response.body}");
      }
    } catch (e) {
      debugPrint(" Exception fetching profile: $e");
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
    final gradient = const LinearGradient(
      colors: [Color(0xFF0D1117), Color(0xFF12151A)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Profile",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(gradient: gradient),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                  child: Column(
                    children: [
                      //  Profile Image
                      Center(
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            const CircleAvatar(
                              radius: 65,
                              backgroundImage:
                                  AssetImage("images/profile.jpeg"),
                            ),
                            Container(
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blueAccent,
                                ),
                                onPressed: _navigateToEditProfile,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),

                      //  Profile Info
                      _buildInfoCard("First Name", firstName),
                      const SizedBox(height: 16),
                      _buildInfoCard("Last Name", lastName),
                      const SizedBox(height: 16),
                      _buildInfoCard("Email", email),
                      const SizedBox(height: 16),
                      _buildInfoCard("Phone",
                          phone.isNotEmpty ? phone : "Not set yet"),

                      const SizedBox(height: 40),

                      //  Edit Button
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
              ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
