import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class SignUpButtons extends StatelessWidget {
  final VoidCallback onEmailSignUp;
  final VoidCallback onGoogleSignUp;
  final VoidCallback? onLinkedInSignUp;

  const SignUpButtons({
    super.key,
    required this.onEmailSignUp,
    required this.onGoogleSignUp,
    this.onLinkedInSignUp,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildMainButton("Sign Up", onEmailSignUp),
        const SizedBox(height: 16),
        _buildSocialButton(
          context,
          text: "Sign up with Google",
          logoUrl:
              "https://upload.wikimedia.org/wikipedia/commons/0/09/IOS_Google_icon.png",
          onTap: onGoogleSignUp,
        ),
        const SizedBox(height: 12),
        _buildSocialButton(
          context,
          text: "Sign up with LinkedIn (Coming Soon)",
          logoUrl:
              "https://upload.wikimedia.org/wikipedia/commons/c/ca/LinkedIn_logo_initials.png",
          onTap: onLinkedInSignUp,
          enabled: false,
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildSocialButton(
    BuildContext context, {
    required String text,
    required String logoUrl,
    VoidCallback? onTap,
    bool enabled = true,
  }) {
    final content = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.network(logoUrl, width: 24, height: 24),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(enabled ? 1 : 0.6),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );

    final button = Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(enabled ? 0.1 : 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white24.withOpacity(enabled ? 1 : 0.4),
        ),
      ),
      child: Center(child: content),
    );

    if (!enabled) {
      return Tooltip(
        message: "LinkedIn authentication will be available soon",
        child: IgnorePointer(child: button),
      );
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: button,
    );
  }
}
