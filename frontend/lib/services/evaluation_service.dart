import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EvaluationService {
  static const String baseUrl = 'http://127.0.0.1:8000/api/study-sessions';

  static Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static Future<String> evaluate({
    required int studySessionId,
    required String text,
  }) async {
    final uri = Uri.parse('$baseUrl/$studySessionId/evaluate');
    final response = await http.post(
      uri,
      headers: await _headers(),
      body: jsonEncode({'text': text}),
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal mengevaluasi. Coba lagi.');
    }

    final data = jsonDecode(response.body);
    return data['feedback'] ?? '';
  }
}
