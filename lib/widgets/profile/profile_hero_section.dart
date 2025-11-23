import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_network_image.dart';

class ProfileHeroSection extends StatelessWidget {
  final String? profilePicUrl;
  final String firstName;
  final String lastName;
  final String email;
  final String? accountType;
  final VoidCallback? onEditImage;

  const ProfileHeroSection({
    super.key,
    this.profilePicUrl,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.accountType,
    this.onEditImage,
  });

  String _getAccountTypeLabel(String? type) {
    if (type == null) return 'User';
    switch (type.toLowerCase()) {
      case 'investor':
        return 'Investor';
      case 'owner':
      case 'entrepreneur':
        return 'Owner';
      case 'admin':
        return 'Admin';
      default:
        return 'User';
    }
  }

  Color _getAccountTypeColor(String? type) {
    if (type == null) return Colors.grey;
    switch (type.toLowerCase()) {
      case 'investor':
        return Colors.blue;
      case 'owner':
      case 'entrepreneur':
        return Colors.green;
      case 'admin':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Widget _buildAvatarPlaceholder(String name, ThemeData theme) {
    final initials = name.isNotEmpty
        ? name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join()
        : '?';
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.secondary,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: Text(
          initials.toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 40,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final fullName = '$firstName $lastName'.trim();
    final accountTypeLabel = _getAccountTypeLabel(accountType);
    final accountTypeColor = _getAccountTypeColor(accountType);

    return Container(
      decoration: BoxDecoration(
        gradient: isDark
            ? const LinearGradient(
                colors: [
                  Color(0xFF1A237E),
                  Color(0xFF283593),
                  Color(0xFF3949AB),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : AppColors.mainGradient,
      ),
      child: Stack(
        children: [
          // Decorative elements
          Positioned(
            top: -30,
            right: -30,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -20,
            left: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
            child: Column(
              children: [
                // Profile Picture
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: profilePicUrl != null && profilePicUrl!.isNotEmpty
                          ? ClipOval(
                              child: AppNetworkImage(
                                imageUrl: profilePicUrl!,
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                                errorWidget: _buildAvatarPlaceholder(fullName, theme),
                                placeholder: _buildAvatarPlaceholder(fullName, theme),
                              ),
                            )
                          : _buildAvatarPlaceholder(fullName, theme),
                    ),
                    if (onEditImage != null)
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.button,
                          border: Border.all(
                            color: Colors.white,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.camera_alt, size: 20),
                          color: Colors.white,
                          onPressed: onEditImage,
                          padding: const EdgeInsets.all(8),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                // Name
                Text(
                  fullName.isNotEmpty ? fullName : 'User',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Account Type Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: accountTypeColor.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: accountTypeColor.withOpacity(0.5),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        accountType?.toLowerCase() == 'investor'
                            ? Icons.trending_up
                            : accountType?.toLowerCase() == 'owner' ||
                                    accountType?.toLowerCase() == 'entrepreneur'
                                ? Icons.business
                                : Icons.admin_panel_settings,
                        size: 18,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        accountTypeLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Email
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.email_outlined,
                      size: 18,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      email,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white.withOpacity(0.9),
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

