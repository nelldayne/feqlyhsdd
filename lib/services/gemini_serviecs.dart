import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/config.dart';

class GeminiService {
  final String apiUrl = "${Appconfig.apiBaseUrl}/gemini";

  Future<String> sendMessage(String message) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/ms'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"message": message}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["reply"] ?? "Không có phản hồi từ chatbot.";
      } else {
        return "Lỗi từ server: ${response.statusCode}";
      }
    } catch (e) {
      return "Lỗi kết nối: $e";
    }
  }
}
