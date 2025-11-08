import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../core/theme/app_spacing.dart';
import '../theme/app_colors.dart';
import '../widgets/status_chip.dart';
import '../widgets/ui_card.dart';
import 'edit_profile_screen.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _profileImage;
  String firstName = 'Mahmoud';
  String lastName = 'Diab';
  String email = 'mahmoud@example.com';
  String phone = '+20 103 209 2421';

  Future<void> _pickImage() async {
    final XFile? picked =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _profileImage = File(picked.path));
    }
  }

  Future<void> _exportProfile() async {
    final Map<String, dynamic> payload = <String, dynamic>{
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
    };
    final String json = const JsonEncoder.withIndent('  ').convert(payload);

    await Clipboard.setData(ClipboardData(text: json));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile exported to clipboard'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  Future<void> _editProfile() async {
    final dynamic result = await Navigator.push(
      context,
      MaterialPageRoute<dynamic>(
        builder: (BuildContext context) => EditProfileScreen(
          firstName: firstName,
          lastName: lastName,
          email: email,
          phone: phone,
          image: _profileImage,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        firstName = result['firstName'] as String? ?? firstName;
        lastName = result['lastName'] as String? ?? lastName;
        email = result['email'] as String? ?? email;
        phone = result['phone'] as String? ?? phone;
        _profileImage = result['image'] as File? ?? _profileImage;
      });
    }
  }

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute<Widget>(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String initials =
        '${firstName.isNotEmpty ? firstName[0] : ''}${lastName.isNotEmpty ? lastName[0] : ''}'
            .toUpperCase();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(color: Colors.white)),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppColors.mainGradient),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UiCard(
              leading: Stack(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    backgroundImage: _profileImage != null
                        ? FileImage(_profileImage!)
                        : null,
                    child: _profileImage == null
                        ? Text(
                            initials.isNotEmpty ? initials : 'ME',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.accent,
                        child: const Icon(
                          Icons.camera_alt,
                          size: 16,
                          color: AppColors.heading,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              title: '$firstName $lastName',
              subtitle: 'Entrepreneur',
              trailing: StatusChip(
                label: 'Profile 85% complete',
                tone: StatusTone.info,
                icon: Icons.auto_graph,
              ),
              child: Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _editProfile,
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Edit profile'),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  OutlinedButton.icon(
                    onPressed: _exportProfile,
                    icon: const Icon(Icons.file_download_outlined, size: 18),
                    label: const Text('Export'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            UiCard(
              title: 'Contact details',
              child: Column(
                children: [
                  _DetailTile(
                    icon: Icons.person_outline,
                    label: 'First name',
                    value: firstName,
                  ),
                  _DetailTile(
                    icon: Icons.person,
                    label: 'Last name',
                    value: lastName,
                  ),
                  _DetailTile(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: email,
                  ),
                  _DetailTile(
                    icon: Icons.phone_outlined,
                    label: 'Phone',
                    value: phone,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            UiCard(
              title: 'Account actions',
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.lock_reset_outlined),
                    title: const Text('Reset password'),
                    subtitle: const Text(
                      'We’ll send a secure reset link to your email',
                    ),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Password reset instructions will be sent to your email.',
                          ),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.logout, color: AppColors.danger),
                    title: const Text('Logout'),
                    onTap: _logout,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailTile extends StatelessWidget {
  const _DetailTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppColors.primary),
      title: Text(label),
      subtitle: Text(value),
    );
  }
}
