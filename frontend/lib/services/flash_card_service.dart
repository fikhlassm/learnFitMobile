import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class FlashcardService {
  /// Helper untuk mengambil headers dengan token otomatis
  static Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// METHOD BARU: Fetch Total Flashcards
  static Future<int> getTotalFlashcards() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.flashcardsTotal),
        headers: await _headers(), // Menggunakan helper headers
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Mengambil nilai dari struktur { "data": { "total": 2 } }
        // Safe access: cek apakah data['data'] ada sebelum akses ['total']
        final total = data['data']?['total'];
        return (total is int) ? total : 0;
      } else {
        // Jika 403 atau error lain, print body untuk debugging
        print('ERROR GET TOTAL BODY: ${response.body}');
      }
    } catch (e) {
      print('Error fetching total flashcards: $e');
    }
    return 0;
  }

  static Future<List<dynamic>> getFlashcards({
    required int studySessionId,
  }) async {
    print('FLASHCARD SESSION ID = $studySessionId');

    final response = await http.get(
      Uri.parse('${ApiConfig.flashcards}?study_session_id=$studySessionId'),
      headers: await _headers(),
    );

    print('FLASHCARD GET STATUS = ${response.statusCode}');
    print('FLASHCARD GET BODY = ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data is List) {
        return data;
      }

      if (data['data'] != null) {
        return data['data'];
      }

      return [];
    }
    throw Exception('Failed to load flashcards');
  }

  static Future<void> createFlashcard({
    required int studySessionId,
    required String question,
    required String answer,
  }) async {
    print('CREATE FLASHCARD SESSION = $studySessionId');

    final response = await http.post(
      Uri.parse(ApiConfig.flashcards),
      headers: await _headers(),
      body: jsonEncode({
        'study_session_id': studySessionId,
        'question': question,
        'answer': answer,
      }),
    );

    print('CREATE STATUS = ${response.statusCode}');
    print('CREATE BODY = ${response.body}');

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to create flashcard');
    }
  }

  static Future<void> updateFlashcard({
    required int id,
    required String question,
    required String answer,
  }) async {
    final response = await http.patch(
      Uri.parse(ApiConfig.flashcard(id)),
      headers: await _headers(),
      body: jsonEncode({
        'question': question,
        'answer': answer,
      }),
    );

    print('UPDATE STATUS = ${response.statusCode}');
    print('UPDATE BODY = ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Failed to update flashcard');
    }
  }

  static Future<void> deleteFlashcard({
    required int id,
  }) async {
    final response = await http.delete(
      Uri.parse(ApiConfig.flashcard(id)),
      headers: await _headers(),
    );

    print('DELETE STATUS = ${response.statusCode}');
    print('DELETE BODY = ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Failed to delete flashcard');
    }
  }
}