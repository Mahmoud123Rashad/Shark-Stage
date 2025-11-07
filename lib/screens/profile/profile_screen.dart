// lib/screens/profile/profile_screen.dart
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'profile_body.dart';

class ProfileScreen extends StatelessWidget {
  final String email;
  const ProfileScreen({super.key, required this.email});

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
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(gradient: gradient),
        child: ProfileBody(email: email), // 👈 محتوى الشاشة في ملف منفصل
      ),
    );
  }
}
