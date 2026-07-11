import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

/// A file attached to a study session as persisted on the backend.
class Attachment {
  final int id;
  final String fileName;

  const Attachment({required this.id, required this.fileName});

  factory Attachment.fromJson(Map<String, dynamic> json) => Attachment(
        id: json['id'] as int,
        fileName: (json['file_name'] ?? '') as String,
      );
}

class AttachmentService {
  static Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return {
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Uploads [file] and returns the created attachment (including its backend id
  /// so the caller can later delete it and keep local/remote state in sync).
  static Future<Attachment> upload({
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

    final data = jsonDecode(response.body);
    return Attachment.fromJson(data['data'] as Map<String, dynamic>);
  }

  /// Returns the attachments currently persisted for [studySessionId].
  static Future<List<Attachment>> list(int studySessionId) async {
    final response = await http.get(
      Uri.parse(ApiConfig.studySessionAttachment(studySessionId)),
      headers: await _headers(),
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal memuat lampiran');
    }

    final data = jsonDecode(response.body);
    final list = (data['data'] as List?) ?? const [];
    return list
        .map((e) => Attachment.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Deletes a persisted attachment from the backend (record + storage +
  /// derived document chunks). Treats a 404 as already-deleted (idempotent).
  static Future<void> delete({
    required int studySessionId,
    required int attachmentId,
  }) async {
    final response = await http.delete(
      Uri.parse(
        ApiConfig.studySessionAttachmentItem(studySessionId, attachmentId),
      ),
      headers: await _headers(),
    );

    if (response.statusCode != 200 && response.statusCode != 204 &&
        response.statusCode != 404) {
      throw Exception('Gagal menghapus dokumen');
    }
  }
}
