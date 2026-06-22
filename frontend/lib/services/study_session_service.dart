import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class StudySessionService {
  static Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static Future<List<dynamic>> getStudySessions() async {
    final response = await http.get(
      Uri.parse(ApiConfig.studySessions),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is List) return data;
      if (data['data'] != null) return data['data'];
      return [];
    }

    throw Exception('Failed to load study sessions');
  }

  static Future<dynamic> getStudySession(int id) async {
    final response = await http.get(
      Uri.parse(ApiConfig.studySession(id)),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception('Failed to load session');
  }

  // ← DIUBAH: return Map supaya bisa ambil 'id' dari response
  static Future<Map<String, dynamic>> createStudySession({
    required String topic,
    required int studyTechniqueId,
  }) async {
    final response = await http.post(
      Uri.parse(ApiConfig.studySessions),
      headers: await _headers(),
      body: jsonEncode({
        'topic': topic,
        'study_technique_id': studyTechniqueId,
      }),
    );

    print(response.statusCode);
    print(response.body);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to create session');
    }

    return jsonDecode(response.body);
  }

  static Future<void> updateStudySession({
    required int id,
    String? topic,
    String? content,
  }) async {
    final body = <String, dynamic>{};
    if (topic != null) body['topic'] = topic;
    if (content != null) body['content'] = content;
    final response = await http.patch(
      Uri.parse(ApiConfig.studySession(id)),
      headers: await _headers(),
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update session');
    }
  }

  static Future<void> deleteStudySession(int id) async {
    final response = await http.delete(
      Uri.parse(ApiConfig.studySession(id)),
      headers: await _headers(),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete session');
    }
  }
}