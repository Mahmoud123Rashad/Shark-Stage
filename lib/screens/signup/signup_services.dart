import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/auth_storage.dart';
import '../../theme/app_colors.dart';
import '../login/login_screen.dart';

class SignUpServices {
  void _showSnack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.button.withOpacity(0.95),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> signUpWithEmail({
    required BuildContext context,
    required String first,
    required String last,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      final response = await ApiService.post(
        'auth/signup',
        body: {
          'firstName': first,
          'lastName': last,
          'email': email,
          'password': password,
          'accountType': role,
        },
      );

      final status = response['status'] as int? ?? 500;
      final success = response['success'] == true;

      if ((status == 200 || status == 201) && success) {
        final userRaw = response['user'];
        final user = userRaw is Map<String, dynamic>
            ? Map<String, dynamic>.from(userRaw)
            : <String, dynamic>{
                'firstName': first,
                'lastName': last,
                'email': email,
                'accountType': role,
              };
        final token = response['token']?.toString();
        if (token != null && token.isNotEmpty) {
          await AuthStorage.saveSession(token: token, user: user);
        } else {
          await AuthStorage.saveUser(user);
        }

        _showSnack(
          context,
          response['message'] ?? "Account created successfully",
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      } else {
        _showSnack(
          context,
          response['message'] ?? 'Error $status',
        );
      }
    } catch (e) {
      _showSnack(context, "Failed to connect: $e");
    }
  }

  Future<void> signInWithGoogle(BuildContext context, String role) async {
    _showSnack(
      context,
      "Google sign-in is temporarily unavailable on mobile. Please use email sign-up.",
    );
  }

  Future<void> signInWithLinkedIn(BuildContext context, String role) async {
    _showSnack(
      context,
      "LinkedIn sign-in is not supported yet. Please continue with email.",
    );
  }
}
