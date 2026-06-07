import 'dart:convert';
import 'package:http/http.dart' as http;

class SessionLogService {

  static const String baseUrl =
      'http://127.0.0.1:8000/api/session-logs';

  static Future<void> createSessionLog({
    required int studySessionId,
    required int durationSeconds,
  }) async {

    final response = await http.post(
      Uri.parse(baseUrl),

      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },

      body: jsonEncode({
        'study_session_id':
            studySessionId,

        'duration_seconds':
            durationSeconds,
      }),
    );

    if (response.statusCode != 200 &&
        response.statusCode != 201) {

      throw Exception(
        'Failed to save session log',
      );
    }
  }

  static Future<List<dynamic>>
      getSessionLogs() async {

    final response = await http.get(
      Uri.parse(baseUrl),

      headers: {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {

      final data =
          jsonDecode(response.body);

      if (data is List) {
        return data;
      }

      if (data['data'] != null) {
        return data['data'];
      }

      return [];
    }

    throw Exception(
      'Failed to load session logs',
    );
  }
}