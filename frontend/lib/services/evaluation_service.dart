import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class EvaluationService {
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
    final uri = Uri.parse(ApiConfig.studySessionEvaluate(studySessionId));
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
