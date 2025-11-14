import 'package:finial_project/services/api_service.dart';

class ProjectOffersService {
  static Future<List<dynamic>> fetchOffers(String projectId) async {
    try {
      // استخدم get الموجود في ApiService مباشرة
      final response = await ApiService.get('offer/received?projectId=$projectId');

      if (response != null && response['offers'] != null) {
        return List<dynamic>.from(response['offers']);
      }

      return [];
    } catch (e) {
      print("Error fetching offers: $e");
      return [];
    }
  }
}
