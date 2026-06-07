import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class QuizResultService {
  static const String baseUrl = 'http://127.0.0.1:8000/api/quiz-results';

  static Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static Future<void> storeQuizResult({
    required int studyTechniqueId,
  }) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: await _headers(),
      body: jsonEncode({'study_technique_id': studyTechniqueId}),
    );

    print(response.statusCode);
    print(response.body);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to store quiz result');
    }
  }
}