import '../../services/api_service.dart';
import '../../services/auth_storage.dart';

class LoginService {
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await ApiService.post(
        'auth/signin',
        body: {'email': email, 'password': password},
      );

      final status = response['status'] as int? ?? 500;
      final success = response['success'] == true;

      if ((status == 200 || status == 201) && success) {
        final token = response['token']?.toString();
        final userRaw = response['user'];
        final user = userRaw is Map<String, dynamic>
            ? Map<String, dynamic>.from(userRaw)
            : <String, dynamic>{};

        if (token != null && token.isNotEmpty) {
          await AuthStorage.saveSession(token: token, user: user);
        } else {
          await AuthStorage.saveUser(user);
        }

        return {
          'success': true,
          'message': response['message'] ?? 'Logged in successfully',
          'user': user,
          'token': token,
          'role': user['accountType']?.toString().toLowerCase(),
        };
      }

      return {
        'success': false,
        'message': response['message'] ?? 'Login failed',
        'status': status,
      };
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> loginWithGoogle({
    required String idToken,
  }) async {
    try {
      final response = await ApiService.post(
        'auth/google',
        body: {
          'idToken': idToken,
          'intent': 'signin',
        },
      );

      final status = response['status'] as int? ?? 500;
      final success = response['success'] == true;

      if ((status == 200 || status == 201) && success) {
        final token = response['token']?.toString();
        final userRaw = response['user'];
        final user = userRaw is Map<String, dynamic>
            ? Map<String, dynamic>.from(userRaw)
            : <String, dynamic>{};

        if (token != null && token.isNotEmpty) {
          await AuthStorage.saveSession(token: token, user: user);
        } else {
          await AuthStorage.saveUser(user);
        }

        return {
          'success': true,
          'message': response['message'] ?? 'Logged in successfully',
          'user': user,
          'token': token,
          'role': user['accountType']?.toString().toLowerCase(),
        };
      }

      return {
        'success': false,
        'message': response['message'] ?? 'Google login failed',
        'status': status,
      };
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }
}
