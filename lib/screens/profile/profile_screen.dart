import 'package:flutter/material.dart';
import 'profile_body.dart';

class ProfileScreen extends StatefulWidget {
  final String email;
  const ProfileScreen({super.key, required this.email});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Profile",
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface, // يغير اللون حسب الـ theme
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorScheme.surface.withOpacity(0.95),
              colorScheme.surface.withOpacity(1),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ProfileBody(email: widget.email), // 👈 محتوى الشاشة في ملف منفصل
      ),
    );
  }
}
