import 'dart:convert';
import 'package:http/http.dart' as http;

class StudySessionService {

  static const String baseUrl =
      'http://10.0.2.2:8000/api/study-sessions';

  static Future<List<dynamic>>
      getStudySessions() async {

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
      'Failed to load study sessions',
    );
  }

  static Future<dynamic>
      getStudySession(int id) async {

    final response = await http.get(
      Uri.parse('$baseUrl/$id'),

      headers: {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {

      return jsonDecode(response.body);
    }

    throw Exception(
      'Failed to load session',
    );
  }

  static Future<void> createStudySession({
    required String topic,
    required int studyTechniqueId,
  }) async {

    final response = await http.post(
      Uri.parse(baseUrl),

      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },

      body: jsonEncode({
        'topic': topic,
        'study_technique_id':
            studyTechniqueId,
      }),
    );

    if (response.statusCode != 200 &&
        response.statusCode != 201) {

      throw Exception(
        'Failed to create session',
      );
    }
  }

  static Future<void> updateStudySession({
    required int id,
    required String content,
  }) async {

    final response = await http.patch(
      Uri.parse('$baseUrl/$id'),

      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },

      body: jsonEncode({
        'content': content,
      }),
    );

    if (response.statusCode != 200) {

      throw Exception(
        'Failed to update session',
      );
    }
  }

  static Future<void>
      deleteStudySession(int id) async {

    final response = await http.delete(
      Uri.parse('$baseUrl/$id'),

      headers: {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {

      throw Exception(
        'Failed to delete session',
      );
    }
  }
}