import '../../services/api_service.dart';

class ProjectDetailsService {
  static Future<Map<String, dynamic>?> fetchProjectDetails(
      String projectId) async {
    try {
      final response = await ApiService.get('projects/$projectId');
      final status = response['status'] as int? ?? 500;
      if (status == 200) {
        final data = response['project'];
        if (data is Map<String, dynamic>) {
          return Map<String, dynamic>.from(data);
        }
        return response;
      }
      throw Exception(
        response['message'] ?? 'Failed to load project details (status $status)',
      );
    } catch (e) {
      // ignore: avoid_print
      print("❌ Error fetching project details: $e");
      return null;
    }
  }
}
