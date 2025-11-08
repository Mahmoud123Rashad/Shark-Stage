import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../services/api_service.dart';
import '../../services/auth_storage.dart';
import '../../theme/app_colors.dart';
import '../login/login_screen.dart';

class SignUpServices {
  static const String _googleServerClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
    defaultValue:
        '470415610035-cfs53teofut74q419c1p19oisfrve7ur.apps.googleusercontent.com',
  );

  GoogleSignIn _buildGoogleSignIn() {
    return GoogleSignIn(
      scopes: const ['email'],
      serverClientId: _googleServerClientId,
    );
  }

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
        _showSnack(context, response['message'] ?? 'Error $status');
      }
    } catch (e) {
      _showSnack(context, "Failed to connect: $e");
    }
  }

  Future<void> signInWithGoogle(BuildContext context, String role) async {
    final messenger = ScaffoldMessenger.of(context);
    final googleSignIn = _buildGoogleSignIn();

    try {
      await googleSignIn.signOut();
      final account = await googleSignIn.signIn();
      if (account == null) {
        return;
      }

      final auth = await account.authentication;
      final authCode = auth.serverAuthCode;

      if (authCode == null || authCode.isEmpty) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Unable to retrieve Google authorization code.'),
          ),
        );
        return;
      }

      final response = await ApiService.post(
        'auth/google',
        body: {'code': authCode, 'accountType': role, 'intent': 'signup'},
      );

      final status = response['status'] as int? ?? 500;
      final success = response['success'] == true;

      if ((status == 200 || status == 201) && success) {
        final userRaw = response['user'];
        final user = userRaw is Map<String, dynamic>
            ? Map<String, dynamic>.from(userRaw)
            : <String, dynamic>{'accountType': role};
        final token = response['token']?.toString();
        if (token != null && token.isNotEmpty) {
          await AuthStorage.saveSession(token: token, user: user);
        } else {
          await AuthStorage.saveUser(user);
        }

        messenger.showSnackBar(
          SnackBar(
            content: Text(
              response['message'] ?? 'Signed up with Google successfully',
            ),
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      } else {
        final message =
            response['message'] ??
            (response['error']?.toString() ??
                'Google sign-in failed ($status)');
        messenger.showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Google sign-in error: $e')),
      );
    } finally {
      await googleSignIn.signOut();
    }
  }

  Future<void> signInWithLinkedIn(BuildContext context, String role) async {
    _showSnack(
      context,
      "LinkedIn sign-in is not supported yet. Please continue with email.",
    );
  }
}
