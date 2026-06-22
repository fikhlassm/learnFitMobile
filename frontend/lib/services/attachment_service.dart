import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class AttachmentService {
  static Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    return {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static Future<void> upload({
    required int studySessionId,
    required File file,
  }) async {
    final uri = Uri.parse(ApiConfig.studySessionAttachment(studySessionId));
    final request = http.MultipartRequest('POST', uri);

    request.headers.addAll(await _headers());
    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Gagal mengunggah dokumen');
    }
  }
}
