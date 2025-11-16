
import 'package:finial_project/services/api_service.dart';

class ProjectDetailsService {
  static Future<Map<String, dynamic>?> fetchProjectDetails(
      String projectId) async {
    try {
      final response = await ApiService.get('projects/$projectId', auth: true);
      final status = response['status'] as int? ?? 500;
      if (status == 200) {
        // Try common keys
        final possibleKeys = ['project', 'oneProject', 'data'];
        for (final key in possibleKeys) {
          final val = response[key];
          if (val is Map<String, dynamic>) {
            return Map<String, dynamic>.from(val);
          }
        }
        // If API returns the project at top-level, ensure it looks like a project
        if (response['_id'] != null || response['title'] != null) {
          return Map<String, dynamic>.from(response);
        }
        return null;
      }
      throw Exception(
        response['message'] ?? 'Failed to load project details (status $status)',
      );
    } catch (e) {
      // ignore: avoid_print
      print(" Error fetching project details: $e");
      return null;
    }
  }
}
