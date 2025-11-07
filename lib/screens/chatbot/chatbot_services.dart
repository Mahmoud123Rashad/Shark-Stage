import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatBotService {
  static const String baseUrl = "http://10.189.241.195:5000/chatbot/ask";

  static Future<String> sendMessage(String message) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "question": message,
          "language": "ar",
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["answer"] ?? "حدث خطأ في الرد.";
      } else {
        return "حدث خطأ في الاتصال (${response.statusCode})";
      }
    } catch (e) {
      return "Connect tothe server failed";
    }
  }
}
