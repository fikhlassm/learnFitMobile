import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // Import wajib untuk bypass AuthService

const String _baseUrl = 'http://127.0.0.1:8000/api';

// ─────────────────────────────────────────────────────────────────────────────
// Model QuizResult
// ─────────────────────────────────────────────────────────────────────────────
class QuizResult {
  final int id;
  final int studyTechniqueId;
  final int pomodoroScore;
  final int activeRecallScore;
  final int feynmanScore;
  final int blurtingScore;
  final String createdAt;

  const QuizResult({
    required this.id,
    required this.studyTechniqueId,
    required this.pomodoroScore,
    required this.activeRecallScore,
    required this.feynmanScore,
    required this.blurtingScore,
    required this.createdAt,
  });

  factory QuizResult.fromJson(Map<String, dynamic> json) => QuizResult(
        id: int.parse(json['id'].toString()),
        studyTechniqueId: int.parse(json['study_technique_id'].toString()),
        pomodoroScore: int.parse(json['pomodoro_score'].toString()),
        activeRecallScore: int.parse(json['active_recall_score'].toString()),
        feynmanScore: int.parse(json['feynman_score'].toString()),
        blurtingScore: int.parse(json['blurting_score'].toString()),
        createdAt: json['created_at']?.toString() ?? '',
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Result wrapper
// ─────────────────────────────────────────────────────────────────────────────
class QuizResultResponse<T> {
  final T? data;
  final String? error;
  bool get isSuccess => error == null;

  const QuizResultResponse.success(this.data) : error = null;
  const QuizResultResponse.failure(this.error) : data = null;
}

// ─────────────────────────────────────────────────────────────────────────────
// QuizResultService
// ────────────────────────────────────────────────────────────────────────────
class QuizResultService {
  QuizResultService._();

  // ── Header helper (PERBAIKAN UTAMA DI SINI) ────────────────────────────────
  static Future<Map<String, String>> _authHeaders() async {
    // Mengambil token LANGSUNG dari SharedPreferences
    // Ini menghindari error "abstract interface class" dari AuthService
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ── Error parser ───────────────────────────────────────────────────────────
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

  // ── Store ─────────────────────────────────────────────────────────────────

  /// POST /api/quiz-results
  static Future<QuizResultResponse<QuizResult>> store({
    required int studyTechniqueId,
    required int pomodoroScore,
    required int activeRecallScore,
    required int feynmanScore,
    required int blurtingScore,
  }) async {
    try {
      // Panggil method _authHeaders() dengan tanda kurung ()
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
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final dataJson = body['data'] as Map<String, dynamic>? ?? body;
        return QuizResultResponse.success(QuizResult.fromJson(dataJson));
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