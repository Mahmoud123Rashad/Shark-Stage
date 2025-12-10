import 'package:flutter/material.dart';
import '../edit_profile/edit_profile_screen.dart';
import 'profile_info_card.dart';
import '../../widgets/profile/profile_hero_section.dart';
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
  String? profilePicUrl;
  String? accountType;
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
        profilePicUrl = cached['profilePicUrl'];
        accountType = cached['accountType']?.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _fetchProfile() async {
    final data = await ProfileService.fetchProfile();
    if (!mounted) return;

    if (data != null) {
      debugPrint("Profile data fetched: $data");
      debugPrint("Profile pic URL: ${data['profilePicUrl']}");
      setState(() {
        firstName = data['firstName'] ?? '';
        lastName = data['lastName'] ?? '';
        email = data['email'] ?? widget.email;
        profilePicUrl = data['profilePicUrl'];
        accountType = data['accountType']?.toString();
        isLoading = false;
      });
    } else {
      debugPrint("Profile data is null");
      // For testing: set a sample profile picture URL if none exists
      // Uncomment the line below to test with a sample image
      profilePicUrl = 'https://via.placeholder.com/120x120?text=Test';
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
        ),
      ),
    );

    if (updatedData != null && mounted) {
      setState(() {
        firstName = updatedData['firstName'] ?? firstName;
        lastName = updatedData['lastName'] ?? lastName;
      });
      // Refresh profile to get updated data
      await _fetchProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return isLoading
        ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
        : CustomScrollView(
            slivers: [
              // Hero Section
              SliverToBoxAdapter(
                child: ProfileHeroSection(
                  profilePicUrl: profilePicUrl,
                  firstName: firstName,
                  lastName: lastName,
                  email: email,
                  accountType: accountType,
                  onEditImage: _pickAndUploadImage,
                ),
              ),
              // Info Cards Section
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Section Title
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.person_outline,
                              color: colorScheme.primary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Personal Information',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // First Name
                    ProfileInfoCard(
                      label: "First Name",
                      value: firstName.isNotEmpty ? firstName : 'Not set',
                      icon: Icons.badge_outlined,
                    ),
                    const SizedBox(height: 16),
                    // Last Name
                    ProfileInfoCard(
                      label: "Last Name",
                      value: lastName.isNotEmpty ? lastName : 'Not set',
                      icon: Icons.badge_outlined,
                    ),
                    const SizedBox(height: 16),
                    // Email
                    ProfileInfoCard(
                      label: "Email",
                      value: email.isNotEmpty ? email : 'Not set',
                      icon: Icons.email_outlined,
                    ),
                    const SizedBox(height: 32),
                    // Edit Profile Button
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [colorScheme.primary, colorScheme.secondary],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary.withOpacity(0.4),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: _navigateToEditProfile,
                        icon: const Icon(Icons.edit, size: 22),
                        label: const Text(
                          "Edit Profile",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          );
  }
}
