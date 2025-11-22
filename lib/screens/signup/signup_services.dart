import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../services/api_service.dart';
import '../../services/auth_storage.dart';
import '../../theme/app_colors.dart';
import '../entrepreneur_bottom_nav_bar.dart';
import '../investor_bottom_nav_bar.dart';

class SignUpServices {
  /// Google OAuth Server Client ID
  /// 
  /// IMPORTANT: This must match the GOOGLE_CLIENT_ID in the server's .env file.
  /// The serverClientId is the OAuth 2.0 client ID for server-side authentication.
  /// 
  /// To set a custom value, use:
  /// flutter run --dart-define=GOOGLE_SERVER_CLIENT_ID=your_client_id_here
  static const String _googleServerClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
    defaultValue:
        '931356072102-3e3t8tsus96899hdvci9spoj3ha8kqf8.apps.googleusercontent.com',
        // '470415610035-cfs53teofut74q419c1p19oisfrve7ur.apps.googleusercontent.com',
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

  Future<void> _navigateAfterSignup(BuildContext context, Map<String, dynamic> user) async {
    final summary = await AuthStorage.getUserSummary();
    final role = (summary['role'] ?? user['accountType']?.toString())?.toLowerCase() ?? '';
    final email = summary['email'] ?? user['email']?.toString() ?? '';
    final userId = summary['id'] ?? user['_id']?.toString();

    if (role == 'owner' || role == 'entrepreneur') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => EntrepreneurBottomNavBar(
            email: email,
            userId: userId,
            role: role,
          ),
        ),
      );
    } else if (role == 'investor') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => InvestorBottomNavBar(
            email: email,
            userId: userId,
            role: role,
          ),
        ),
      );
    } else {
      _showSnack(context, "Unknown user role");
    }
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
        await _navigateAfterSignup(context, user);
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
      print('🔵 [Google Sign-In] Starting Google sign-in process...');
      print('🔵 [Google Sign-In] Account type: $role');
      print('🔵 [Google Sign-In] Server Client ID: $_googleServerClientId');

      await googleSignIn.signOut();
      print('🔵 [Google Sign-In] Previous session signed out');

      final account = await googleSignIn.signIn();
      if (account == null) {
        print('🟡 [Google Sign-In] User cancelled sign-in');
        return;
      }

      print('🔵 [Google Sign-In] Account selected: ${account.email}');

      final auth = await account.authentication;
      final idToken = auth.idToken;

      if (idToken == null || idToken.isEmpty) {
        print('🔴 [Google Sign-In] ERROR: idToken is null or empty');
        print('🔴 [Google Sign-In] Access token: ${auth.accessToken != null ? "present" : "missing"}');
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Unable to retrieve Google account token. Please try again.'),
            duration: Duration(seconds: 4),
          ),
        );
        return;
      }

      print('🔵 [Google Sign-In] idToken received (length: ${idToken.length})');
      print('🔵 [Google Sign-In] Sending idToken to server...');

      final response = await ApiService.post(
        'auth/google',
        body: {'idToken': idToken, 'accountType': role, 'intent': 'signup'},
      );

      final status = response['status'] as int? ?? 500;
      final success = response['success'] == true;

      print('🔵 [Google Sign-In] Server response: status=$status, success=$success');
      print('🔵 [Google Sign-In] Response message: ${response['message']}');

      if ((status == 200 || status == 201) && success) {
        final userRaw = response['user'];
        final user = userRaw is Map<String, dynamic>
            ? Map<String, dynamic>.from(userRaw)
            : <String, dynamic>{'accountType': role};
        final token = response['token']?.toString();
        if (token != null && token.isNotEmpty) {
          await AuthStorage.saveSession(token: token, user: user);
          print('✅ [Google Sign-In] Session saved successfully');
        } else {
          await AuthStorage.saveUser(user);
          print('✅ [Google Sign-In] User data saved');
        }

        messenger.showSnackBar(
          SnackBar(
            content: Text(
              response['message'] ?? 'Signed up with Google successfully',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
        await _navigateAfterSignup(context, user);
      } else {
        // Extract detailed error message
        String errorMessage = 'فشل التسجيل';
        
        if (response['message'] != null) {
          errorMessage = response['message'].toString();
        } else if (response['error'] != null) {
          errorMessage = response['error'].toString();
        } else if (response['raw'] != null) {
          errorMessage = 'خطأ في الخادم: ${response['raw']}';
        } else {
          errorMessage = 'فشل التسجيل. كود الخطأ: $status';
        }

        print('🔴 [Google Sign-In] ERROR: $errorMessage');
        print('🔴 [Google Sign-In] Full response: $response');

        messenger.showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e, stackTrace) {
      print('🔴 [Google Sign-In] EXCEPTION: $e');
      print('🔴 [Google Sign-In] Stack trace: $stackTrace');
      
      String errorMessage = 'فشل التسجيل';
      String errorDetails = e.toString();
      
      // Handle specific Google Sign-In errors
      if (errorDetails.contains('ApiException: 10') || 
          errorDetails.contains('DEVELOPER_ERROR') ||
          errorDetails.contains('sign_in_failed')) {
        errorMessage = 'خطأ في تكوين Google Sign-In.\n'
            'يرجى التحقق من إعدادات SHA-1 في Firebase Console.\n'
            'للحصول على SHA-1: keytool -list -v -keystore ~/.android/debug.keystore';
      } else if (errorDetails.contains('network') || errorDetails.contains('connection')) {
        errorMessage = 'فشل الاتصال بالخادم. يرجى التحقق من الاتصال بالإنترنت';
      } else if (errorDetails.contains('timeout')) {
        errorMessage = 'انتهت مهلة الاتصال. يرجى المحاولة مرة أخرى';
      } else if (errorDetails.contains('SIGN_IN_CANCELLED') || errorDetails.contains('canceled')) {
        errorMessage = 'تم إلغاء عملية تسجيل الدخول';
        return; // Don't show error for user cancellation
      } else {
        errorMessage = 'حدث خطأ أثناء تسجيل الدخول.\n'
            'يرجى المحاولة مرة أخرى أو استخدام البريد الإلكتروني';
      }

      messenger.showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 6),
          action: SnackBarAction(
            label: 'إغلاق',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
    } finally {
      try {
        await googleSignIn.signOut();
        print('🔵 [Google Sign-In] Cleaned up Google sign-in session');
      } catch (e) {
        print('🟡 [Google Sign-In] Warning: Error during cleanup: $e');
      }
    }
  }

  Future<void> signInWithLinkedIn(BuildContext context, String role) async {
    _showSnack(
      context,
      "LinkedIn sign-in is not supported yet. Please continue with email.",
    );
  }
}
