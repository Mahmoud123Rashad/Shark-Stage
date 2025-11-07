import 'dart:convert';
import 'package:http/http.dart' as http;

class ProjectDetailsService {
  static const String baseUrl = "https://sharkserver-production.up.railway.app";

  static Future<Map<String, dynamic>?> fetchProjectDetails(String projectId) async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/projects/$projectId"));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["project"] ?? data;
      } else {
        throw Exception("Failed to load project details");
      }
    } catch (e) {
      print("❌ Error fetching project details: $e");
      return null;
    }
  }
}
