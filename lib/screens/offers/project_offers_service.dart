import 'package:finial_project/services/api_service.dart';

class ProjectOffersService {
  static Future<List<dynamic>> fetchOffers(String projectId) async {
    try {
      // استخدم get الموجود في ApiService مباشرة
      final response = await ApiService.get(
        'offers/received?projectId=$projectId',
        auth: true,
      );

      if (response['offers'] != null) {
        return List<dynamic>.from(response['offers']);
      }

      return [];
    } catch (e) {
      print("Error fetching offers: $e");
      return [];
    }
  }

  static Future<bool> acceptOffer(String offerId) async {
    try {
      final response = await ApiService.patch(
        'offers/accept/$offerId',
        auth: true,
      );
      final statusCode = response['status'] as int? ?? 500;
      return statusCode == 200 && response['success'] == true;
    } catch (e) {
      print("Error accepting offer: $e");
      return false;
    }
  }

  static Future<bool> rejectOffer(String offerId) async {
    try {
      final response = await ApiService.patch(
        'offers/reject/$offerId',
        auth: true,
      );
      final statusCode = response['status'] as int? ?? 500;
      return statusCode == 200 && response['success'] == true;
    } catch (e) {
      print("Error rejecting offer: $e");
      return false;
    }
  }

  static Future<List<dynamic>> fetchSentOffers() async {
    try {
      final response = await ApiService.get(
        'offers/sent',
        auth: true,
      );

      if (response['offers'] != null) {
        return List<dynamic>.from(response['offers']);
      }

      return [];
    } catch (e) {
      print("Error fetching sent offers: $e");
      return [];
    }
  }

  static Future<bool> cancelOffer(String offerId) async {
    try {
      final response = await ApiService.patch(
        'offers/cancel/$offerId',
        auth: true,
      );
      final statusCode = response['status'] as int? ?? 500;
      return statusCode == 200 && response['success'] == true;
    } catch (e) {
      print("Error cancelling offer: $e");
      return false;
    }
  }
}
