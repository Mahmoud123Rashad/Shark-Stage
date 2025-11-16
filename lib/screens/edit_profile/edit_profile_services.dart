import 'dart:io';
import '../../services/api_service.dart';
import '../../services/auth_storage.dart';
import '../profile/profile_service.dart';

class EditProfileService {
  static Future<Map<String, dynamic>> updateProfile({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    File? image,
    Function(double)? onImageUploadProgress,
  }) async {
    try {
      final body = <String, dynamic>{
        'firstName': firstName,
        'lastName': lastName,
        'phone': phone,
        'email': email,
      };

      final response = await ApiService.patch(
        'auth/profile',
        body: body,
        auth: true,
      );

      final status = response['status'] as int? ?? 500;
      final success = response['success'] == true;

      if (status == 200 && success) {
        final updatedUser = response['user'] is Map<String, dynamic>
            ? Map<String, dynamic>.from(response['user'])
            : <String, dynamic>{};
        await AuthStorage.saveUser(updatedUser);

        if (image != null) {
          final uploadResult = await ProfileService.uploadProfileImage(image);
          if (uploadResult['success'] == true) {
            updatedUser['profilePicUrl'] = uploadResult['imageUrl'];
          } else if (uploadResult['message'] != null) {
            updatedUser['imageError'] = uploadResult['message'];
          }
        }

        return updatedUser;
      }

      return {
        'error': response['message'] ?? 'Failed to update profile',
        'status': status,
      };
    } catch (e) {
      return {'error': 'Error occurred while updating profile: $e'};
    }
  }
}
