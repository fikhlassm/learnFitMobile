import 'dart:convert';
import 'package:http/http.dart' as http;

class FlashcardService {
  // PERBAIKAN: Gunakan localhost untuk Web/iOS, atau 10.0.2.2 untuk Android Emulator
  static const String baseUrl = 'http://localhost:8000/api/flashcards';

  /// METHOD BARU: Mengambil total flashcard user
  static Future<int> getTotalFlashcards(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/total'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json', 
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Mengambil nilai dari struktur { "data": { "total": 2 } }
        return (data['data']['total'] ?? 0) as int;
      } else {
      // Jika 403, print body error dari Laravel agar tahu alasannya
      print('ERROR BODY: ${response.body}'); 
    
      }
    } catch (e) {
      print('Error fetching total flashcards: $e');
    }
    return 0;
  }

  static Future<List<dynamic>> getFlashcards({
    required String token,
    required int studySessionId,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl?study_session_id=$studySessionId'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is List) return data;
      if (data['data'] != null) return data['data'];
      return [];
    }
    throw Exception('Failed to load flashcards');
  }

  static Future<void> createFlashcard({
    required String token,
    required int studySessionId,
    required String question,
    required String answer,
  }) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'study_session_id': studySessionId,
        'question': question,
        'answer': answer,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to create flashcard');
    }
  }

  static Future<void> updateFlashcard({
    required String token,
    required int id,
    required String question,
    required String answer,
  }) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/$id'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'question': question,
        'answer': answer,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update flashcard');
    }
  }

  static Future<void> deleteFlashcard({
    required String token,
    required int id,
  }) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/$id'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete flashcard');
    }
  }
}