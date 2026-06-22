import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class SessionLogService {
  static Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();

    final token =
        prefs.getString('auth_token');

    print(
      'SESSION LOG TOKEN = $token',
    );

    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization':
          'Bearer ${token ?? ''}',
    };
  }

  static Future<void> createSessionLog({
    required int studySessionId,
    required int durationSeconds,
  }) async {

    print(
      'SESSION LOG ID = $studySessionId',
    );

    final response = await http.post(
      Uri.parse(ApiConfig.sessionLogs),

      headers: await _headers(),

      body: jsonEncode({
        'study_session_id':
            studySessionId,

        'duration_seconds':
            durationSeconds,
      }),
    );

    print(
      'SESSION LOG STATUS = ${response.statusCode}',
    );

    print(
      'SESSION LOG BODY = ${response.body}',
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
      Uri.parse(ApiConfig.sessionLogs),

      headers: await _headers(),
    );

    print(
      'GET SESSION LOG STATUS = ${response.statusCode}',
    );

    print(
      'GET SESSION LOG BODY = ${response.body}',
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