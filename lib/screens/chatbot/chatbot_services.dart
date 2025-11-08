import '../../services/api_service.dart';

class ChatBotService {
  static Future<String> sendMessage(String message) async {
    try {
      final response = await ApiService.post(
        'chatbot/ask',
        body: {'question': message, 'language': 'ar'},
      );

      final status = response['status'] as int? ?? 500;
      if (status == 200) {
        final data = response['answer'];
        if (data != null) {
          return data.toString();
        }
        if (response['message'] != null) {
          return response['message'].toString();
        }
        return "حدث خطأ في الرد.";
      }
      return "حدث خطأ في الاتصال ($status)";
    } catch (e) {
      return "Connect to the server failed: $e";
    }
  }
}
