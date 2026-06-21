import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const String _baseUrl = 'http://127.0.0.1:8000/api';

class QuizResultResponse<T> {
  final T? data;
  final String? error;
  bool get isSuccess => error == null;

  const QuizResultResponse.success(this.data) : error = null;
  const QuizResultResponse.failure(this.error) : data = null;
}

class QuizResultService {
  QuizResultService._();

  static Future<Map<String, String>> _authHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static String _parseError(http.Response response) {
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (body.containsKey('errors')) {
        final errors = body['errors'] as Map<String, dynamic>;
        final messages = errors.values
            .whereType<List>()
            .expand((e) => e)
            .map((e) => e.toString())
            .toList();
        if (messages.isNotEmpty) return messages.join('\n');
      }
      if (body.containsKey('message')) return body['message'] as String;
    } catch (_) {}
    return 'Terjadi kesalahan (${response.statusCode})';
  }

  static Future<QuizResultResponse<void>> store({
    required int studyTechniqueId,
  }) async {
    try {
      final headers = await _authHeaders();

      final response = await http.post(
        Uri.parse('$_baseUrl/quiz-results'),
        headers: headers,
        body: jsonEncode({
          'study_technique_id': studyTechniqueId,
        }),
      );

      debugPrint('[QuizResultService] store → ${response.statusCode} ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return const QuizResultResponse.success(null);
      }

      if (response.statusCode == 401) {
        return const QuizResultResponse.failure('Sesi kamu telah berakhir. Silakan login kembali.');
      }

      return QuizResultResponse.failure(_parseError(response));
    } catch (e) {
      debugPrint('[QuizResultService] store exception: $e');
      return const QuizResultResponse.failure('Tidak dapat terhubung ke server.');
    }
  }
}