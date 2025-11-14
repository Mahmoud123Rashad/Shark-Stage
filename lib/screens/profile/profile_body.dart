import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../edit_profile/edit_profile_screen.dart';
import 'profile_info_card.dart';
import 'profile_service.dart';
import '../../services/auth_storage.dart';

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
    _hydrateFromCache();
    _fetchProfile();
  }

  Future<void> _hydrateFromCache() async {
    final cached = await AuthStorage.getUser();
    if (cached != null && mounted) {
      setState(() {
        firstName = cached['firstName'] ?? firstName;
        lastName = cached['lastName'] ?? lastName;
        email = cached['email'] ?? widget.email;
        phone = cached['phone'] ?? phone;
        profilePicUrl = cached['profilePicUrl'];
        isLoading = false;
      });
    }
  }

  Future<void> _fetchProfile() async {
    final data = await ProfileService.fetchProfile();
    if (!mounted) return;

    if (data != null) {
      setState(() {
        firstName = data['firstName'] ?? '';
        lastName = data['lastName'] ?? '';
        email = data['email'] ?? widget.email;
        phone = data['phone'] ?? '';
        profilePicUrl = data['profilePicUrl'];
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return isLoading
        ? Center(
            child: CircularProgressIndicator(
              color: colorScheme.primary,
            ),
          )
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
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colorScheme.surface,
                            boxShadow: [
                              BoxShadow(
                                color: theme.shadowColor.withOpacity(0.3),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.camera_alt,
                              color: colorScheme.primary,
                            ),
                            onPressed: _pickAndUploadImage,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // 🔹 بيانات المستخدم
                  ProfileInfoCard(
                      label: "First Name",
                      value: firstName,
                      valueColor: colorScheme.onSurface),
                  const SizedBox(height: 16),
                  ProfileInfoCard(
                      label: "Last Name",
                      value: lastName,
                      valueColor: colorScheme.onSurface),
                  const SizedBox(height: 16),
                  ProfileInfoCard(
                      label: "Email",
                      value: email,
                      valueColor: colorScheme.onSurface),
                  const SizedBox(height: 16),
                  ProfileInfoCard(
                      label: "Phone",
                      value: phone.isNotEmpty ? phone : "Not set yet",
                      valueColor: colorScheme.onSurface),

                  const SizedBox(height: 40),

                  // 🔹 زر تعديل الملف
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: Icon(Icons.edit, color: colorScheme.onPrimary),
                      label: Text(
                        "Edit Profile",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onPrimary,
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
