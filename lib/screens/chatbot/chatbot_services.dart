import '../../services/api_service.dart';

class ChatBotService {
  static String _detectLanguage(String message) {
    // Check if the message contains Arabic characters (Unicode range 0600-06FF)
    final arabicRegex = RegExp(r'[\u0600-\u06FF]');
    return arabicRegex.hasMatch(message) ? 'ar' : 'en';
  }

  static Future<String> sendMessage(String message) async {
    try {
      final language = _detectLanguage(message);
      final response = await ApiService.post(
        'chatbot/ask',
        body: {'question': message, 'language': language},
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
