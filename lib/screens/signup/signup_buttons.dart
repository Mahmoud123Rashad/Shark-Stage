import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class SignUpButtons extends StatelessWidget {
  final VoidCallback onEmailSignUp;
  final VoidCallback onGoogleSignUp;
  final VoidCallback onLinkedInSignUp;

  const SignUpButtons({
    super.key,
    required this.onEmailSignUp,
    required this.onGoogleSignUp,
    required this.onLinkedInSignUp,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildMainButton("Sign Up", onEmailSignUp),
        const SizedBox(height: 16),
        _buildSocialButton(
          "Sign up with Google",
          "https://upload.wikimedia.org/wikipedia/commons/0/09/IOS_Google_icon.png",
          onGoogleSignUp,
        ),
        const SizedBox(height: 12),
        _buildSocialButton(
          "Sign up with LinkedIn",
          "https://upload.wikimedia.org/wikipedia/commons/c/ca/LinkedIn_logo_initials.png",
          onLinkedInSignUp,
        ),
      ],
    );
  }

  Widget _buildMainButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.button,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: onPressed,
        child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildSocialButton(String text, String logoUrl, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(logoUrl, width: 24, height: 24),
            const SizedBox(width: 12),
            Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
